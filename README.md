# RAG 시스템

LangChain과 pgvector를 사용한 RAG (Retrieval Augmented Generation) 시스템.

## 프로젝트 구조

```
RAG/
├── backend/              # FastAPI 백엔드
│   ├── app/             # 애플리케이션 코드
│   │   ├── api/         # API 라우터
│   │   ├── core/        # 설정 및 데이터베이스
│   │   ├── models/      # Pydantic 모델
│   │   ├── services/    # 비즈니스 로직
│   │   └── main.py      # FastAPI 앱 진입점
│   ├── scripts/         # 유틸리티 스크립트
│   ├── requirements.txt # Python 의존성
│   └── README.md        # 백엔드 문서
├── frontend/            # Next.js 프론트엔드
│   ├── app/            # Next.js 앱
│   ├── components/     # React 컴포넌트
│   └── package.json    # Node.js 의존성
└── libs/               # LangChain 라이브러리 소스 코드
```

## 빠른 시작

### 백엔드 실행

```bash
# 의존성 설치
cd backend
pip install -r requirements.txt

# 서버 실행 (프로젝트 루트에서)
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000

# 또는 backend/run.py 사용
python backend/run.py
```

### 프론트엔드 실행

```bash
cd frontend
npm install
npm run dev
```

### Docker Compose 사용

```bash
docker-compose up
```

## 환경 변수

백엔드 환경 변수 (`.env` 파일 또는 환경 변수로 설정):

- `POSTGRES_HOST`: PostgreSQL 호스트 (기본값: localhost)
- `POSTGRES_PORT`: PostgreSQL 포트 (기본값: 5432)
- `POSTGRES_USER`: PostgreSQL 사용자 (기본값: langchain)
- `POSTGRES_PASSWORD`: PostgreSQL 비밀번호 (기본값: langchain123)
- `POSTGRES_DB`: PostgreSQL 데이터베이스 (기본값: langchain_db)
- `OPENAI_API_KEY`: OpenAI API 키 (선택사항)

## API 엔드포인트

- `GET /`: API 정보
- `GET /api/v1/health`: 헬스 체크
- `POST /api/v1/search`: 유사도 검색
- `POST /api/v1/documents`: 문서 추가
- `GET /docs`: Swagger UI 문서

자세한 내용은 각 디렉토리의 README.md를 참조하세요.
