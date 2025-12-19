"""애플리케이션 설정."""

import os
from pathlib import Path
from typing import Optional

# .env 파일 로드 (python-dotenv는 uvicorn[standard]에 포함됨)
try:
    from dotenv import load_dotenv

    # 프로젝트 루트에서 .env 파일 찾기
    env_path = Path(__file__).parent.parent.parent.parent / ".env"
    if not env_path.exists():
        # backend 디렉토리의 .env 파일 확인
        env_path = Path(__file__).parent.parent.parent / ".env"
    if env_path.exists():
        load_dotenv(env_path)
except ImportError:
    # python-dotenv가 없는 경우 무시 (환경 변수 직접 사용)
    pass


class Settings:
    """애플리케이션 설정 클래스."""

    # Neon PostgreSQL 연결 문자열 (우선순위 높음)
    POSTGRES_CONNECTION_STRING: Optional[str] = os.getenv("POSTGRES_CONNECTION_STRING")

    # 개별 PostgreSQL 설정 (POSTGRES_CONNECTION_STRING이 없을 때 사용)
    POSTGRES_HOST: str = os.getenv("POSTGRES_HOST", "localhost")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "langchain")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "langchain123")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "langchain_db")

    # Vector Store 설정
    COLLECTION_NAME: str = "langchain_collection"

    # OpenAI 설정
    OPENAI_API_KEY: Optional[str] = os.getenv("OPENAI_API_KEY")

    @property
    def connection_string(self) -> str:
        """PostgreSQL 연결 문자열 생성.

        POSTGRES_CONNECTION_STRING이 설정되어 있으면 그것을 사용하고,
        없으면 개별 설정으로부터 연결 문자열을 생성합니다.
        """
        if self.POSTGRES_CONNECTION_STRING:
            # Windows 환경에서 인코딩 문제 해결
            conn_str = self.POSTGRES_CONNECTION_STRING
            # bytes인 경우 UTF-8로 디코딩
            if isinstance(conn_str, bytes):
                conn_str = conn_str.decode("utf-8", errors="replace")
            # 문자열로 변환하여 반환
            return str(conn_str)

        return (
            f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@"
            f"{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )


settings = Settings()
