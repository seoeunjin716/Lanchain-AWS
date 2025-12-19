# OpenAI API 키 발급 및 설정 가이드

## 📋 목차
1. [OpenAI API 키란?](#openai-api-키란)
2. [API 키 발급 단계](#api-키-발급-단계)
3. [환경 변수 설정 방법](#환경-변수-설정-방법)
4. [요금 정보](#요금-정보)
5. [대안 방법](#대안-방법)

---

## OpenAI API 키란?

OpenAI API 키는 OpenAI의 GPT 모델(ChatGPT)을 프로그램에서 사용하기 위한 인증 키입니다.
이 키가 있어야 챗봇이 AI 응답을 생성할 수 있습니다.

---

## API 키 발급 단계

### 1단계: OpenAI 계정 생성

1. **웹 브라우저에서 다음 링크 접속**
   ```
   https://platform.openai.com/signup
   ```

2. **회원가입 방법 선택**
   - 이메일 주소로 가입
   - 또는 Google/Microsoft 계정으로 가입

3. **이메일 인증**
   - 가입 시 입력한 이메일로 인증 메일이 발송됩니다
   - 메일의 인증 링크를 클릭하여 계정 활성화

### 2단계: API 키 생성

1. **OpenAI Platform 로그인**
   ```
   https://platform.openai.com
   ```

2. **API Keys 페이지 이동**
   - 우측 상단 프로필 클릭
   - "API keys" 메뉴 선택
   - 또는 직접 접속: https://platform.openai.com/api-keys

3. **새 API 키 생성**
   - "Create new secret key" 버튼 클릭
   - 키 이름 입력 (예: "LangChain Chatbot")
   - "Create secret key" 클릭

4. **API 키 복사 및 저장**
   - ⚠️ **중요**: 생성된 키는 한 번만 표시됩니다!
   - "Copy" 버튼을 클릭하여 키를 복사
   - 안전한 곳에 저장 (예: 메모장)
   - 키 형식: `sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxx`

---

## 환경 변수 설정 방법

### 방법 1: Docker로 실행하는 경우

1. **프로젝트 루트의 `.env` 파일 수정**
   ```bash
   # 파일 위치: C:\Users\hi\Documents\seoeunjin\langchain\.env
   ```

2. **API 키 입력**
   ```bash
   OPENAI_API_KEY=sk-proj-여기에_발급받은_키를_붙여넣기
   ```

3. **저장 후 Docker Compose 실행**
   ```bash
   docker compose up --build
   ```

### 방법 2: 로컬 개발 (npm으로 실행)

1. **chatbot 폴더의 `.env.local` 파일 수정**
   ```bash
   # 파일 위치: C:\Users\hi\Documents\seoeunjin\langchain\chatbot\.env.local
   ```

2. **API 키 입력**
   ```bash
   OPENAI_API_KEY=sk-proj-여기에_발급받은_키를_붙여넣기
   ```

3. **로컬 개발 서버 실행**
   ```bash
   cd chatbot
   npm install
   npm run dev
   ```

### 설정 예시

**올바른 설정:**
```bash
OPENAI_API_KEY=sk-proj-abc123def456ghi789jkl012mno345pqr678stu901vwx234yz
```

**잘못된 설정:**
```bash
OPENAI_API_KEY=your_openai_api_key_here  ❌ (실제 키가 아님)
OPENAI_API_KEY=                            ❌ (비어있음)
OPENAI_API_KEY = sk-proj-...               ❌ (공백이 있음)
```

---

## 요금 정보

### 신규 가입 혜택
- **$5 무료 크레딧** (2024년 기준)
- 가입 후 3개월간 사용 가능
- 신용카드 등록 필요 없음 (무료 크레딧 사용 시)

### GPT-3.5-Turbo 요금 (현재 프로젝트에서 사용)
- **입력**: $0.50 / 1M 토큰
- **출력**: $1.50 / 1M 토큰
- **예상 비용**: 메시지 1개당 약 $0.001 (1원 미만)

### 사용량 확인
```
https://platform.openai.com/usage
```

### 예산 한도 설정 (권장)
1. Settings → Billing → Usage limits
2. 월 한도 설정 (예: $10)
3. 초과 시 알림 설정

---

## 대안 방법

### 옵션 1: OpenAI API 키 없이 테스트

API 키가 없어도 앱은 작동하며, 다음과 같은 메시지가 표시됩니다:
```
"OpenAI API 키가 설정되지 않았습니다. 환경 변수 OPENAI_API_KEY를 설정해주세요."
```

### 옵션 2: 무료 대안 사용

**Ollama (로컬 AI 모델)**
- 완전 무료
- 인터넷 연결 불필요
- 설정이 더 복잡함

**설정 방법:**
1. Ollama 설치: https://ollama.ai
2. `chatbot/app/api/chat/route.ts` 파일 수정 필요

---

## 빠른 시작 체크리스트

- [ ] OpenAI 계정 생성 (https://platform.openai.com/signup)
- [ ] API 키 발급 (https://platform.openai.com/api-keys)
- [ ] API 키 복사 및 저장
- [ ] `.env` 파일에 API 키 입력 (Docker 사용 시)
- [ ] 또는 `chatbot/.env.local` 파일에 API 키 입력 (로컬 개발 시)
- [ ] 앱 실행 및 테스트

---

## 문제 해결

### "API 키가 유효하지 않습니다" 오류
- API 키를 정확히 복사했는지 확인
- 키 앞뒤에 공백이 없는지 확인
- OpenAI Platform에서 키가 활성 상태인지 확인

### "크레딧이 부족합니다" 오류
- https://platform.openai.com/usage 에서 사용량 확인
- 무료 크레딧이 소진되었을 수 있음
- 결제 방법 추가 필요

### Docker 환경 변수가 인식되지 않음
```bash
# Docker 컨테이너 재시작
docker compose down
docker compose up --build
```

---

## 다음 단계

1. ✅ API 키 발급 완료
2. ✅ 환경 변수 설정 완료
3. 🚀 앱 실행:
   ```bash
   # Docker로 실행
   docker compose up --build

   # 또는 로컬 개발
   cd chatbot
   npm install
   npm run dev
   ```

4. 🌐 브라우저에서 접속:
   ```
   http://localhost:3000
   ```

---

## 추가 리소스

- **OpenAI 문서**: https://platform.openai.com/docs
- **API 키 관리**: https://platform.openai.com/api-keys
- **사용량 대시보드**: https://platform.openai.com/usage
- **요금 정보**: https://openai.com/pricing

