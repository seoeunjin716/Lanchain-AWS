"""데이터베이스 연결 및 초기화."""

from typing import Optional

from langchain_community.vectorstores import PGVector
from langchain_core.documents import Document
from langchain_core.embeddings import Embeddings

from backend.app.core.config import settings


def check_postgres_connection() -> None:
    """PostgreSQL 연결 확인."""
    try:
        import psycopg2

        conn_str = settings.connection_string
        # 문자열로 명시적 변환 (Windows 인코딩 문제 해결)
        if isinstance(conn_str, bytes):
            conn_str = conn_str.decode("utf-8", errors="replace")
        conn_str = str(conn_str)

        conn = psycopg2.connect(conn_str)
        conn.close()
        print("✅ PostgreSQL 연결 확인 완료")
    except Exception as e:
        print(f"⚠️  PostgreSQL 연결 확인 실패: {e}")
        # Neon PostgreSQL은 클라우드 서비스이므로 연결 실패 시에도 계속 진행
        # (네트워크 문제일 수 있음)


def initialize_embeddings() -> Embeddings:
    """Embedding 모델 초기화."""
    from langchain_core.embeddings import FakeEmbeddings

    if settings.OPENAI_API_KEY:
        try:
            from langchain_openai import OpenAIEmbeddings

            return OpenAIEmbeddings()
        except ImportError:
            return FakeEmbeddings(size=1536)
    else:
        return FakeEmbeddings(size=1536)


def initialize_vector_store() -> Optional[PGVector]:
    """PGVector 스토어 초기화."""
    embeddings = initialize_embeddings()

    # Vector store 연결
    vector_store = PGVector(
        embedding_function=embeddings,
        collection_name=settings.COLLECTION_NAME,
        connection_string=settings.connection_string,
    )

    # 초기 문서가 있는지 확인 (문서 수가 0이면 초기 문서 추가)
    try:
        existing_docs = vector_store.similarity_search("", k=1)
        if len(existing_docs) == 0:
            # 초기 문서 추가
            initial_docs = [
                Document(
                    page_content="안녕하세요! 이것은 LangChain과 pgvector의 Hello World 예제입니다.",
                    metadata={"source": "hello_world", "type": "greeting"},
                ),
                Document(
                    page_content="LangChain은 LLM 애플리케이션을 구축하기 위한 프레임워크입니다.",
                    metadata={"source": "langchain_info", "type": "info"},
                ),
                Document(
                    page_content="pgvector는 PostgreSQL에서 벡터 유사도 검색을 가능하게 하는 확장입니다.",
                    metadata={"source": "pgvector_info", "type": "info"},
                ),
            ]
            vector_store.add_documents(initial_docs)
            print("✅ 초기 문서 추가 완료")
        else:
            print("✅ 기존 문서 발견")
    except Exception as e:
        # 에러가 발생해도 계속 진행 (문서 추가는 선택사항)
        print(f"⚠️  초기 문서 추가 중 오류 (무시됨): {e}")

    return vector_store
