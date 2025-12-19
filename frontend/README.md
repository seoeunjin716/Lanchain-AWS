# LangChain Chatbot - PWA

LangChain과 연동된 Next.js 기반 챗봇 애플리케이션입니다.

## 기능

- 🤖 LangChain을 통한 AI 챗봇
- 📱 PWA (Progressive Web App) 지원
- 💬 실시간 채팅 인터페이스
- 🎨 모던하고 반응형 UI

## 시작하기

### 로컬 개발

1. 의존성 설치:
```bash
cd frontend
npm install
```

2. 환경 변수 설정:
```bash
cp .env.example .env.local
# .env.local 파일에 OPENAI_API_KEY 설정
```

3. 개발 서버 실행:
```bash
npm run dev
```

브라우저에서 [http://localhost:3000](http://localhost:3000)을 열어 확인하세요.

### Docker로 실행

프로젝트 루트에서:
```bash
docker compose up --build
```

챗봇은 [http://localhost:3000](http://localhost:3000)에서 접근할 수 있습니다.

## PWA 설치

1. 모바일 브라우저에서 앱을 열기
2. 브라우저 메뉴에서 "홈 화면에 추가" 선택
3. 앱이 홈 화면에 설치됩니다

## 기술 스택

- **Next.js 14** - React 프레임워크
- **TypeScript** - 타입 안정성
- **LangChain** - LLM 통합
- **OpenAI** - GPT 모델
- **PWA** - 오프라인 지원 및 앱 설치

## 프로젝트 구조

```
frontend/
├── app/
│   ├── api/
│   │   └── chat/          # LangChain API 라우트
│   ├── layout.tsx         # 루트 레이아웃
│   ├── page.tsx           # 메인 페이지
│   └── globals.css        # 전역 스타일
├── components/
│   ├── ChatMessage.tsx    # 메시지 컴포넌트
│   └── ChatInput.tsx     # 입력 컴포넌트
├── public/
│   ├── manifest.json      # PWA 매니페스트
│   └── sw.js             # Service Worker
└── package.json
```

