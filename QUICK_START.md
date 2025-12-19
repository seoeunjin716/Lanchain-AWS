# 🚀 빠른 시작 가이드

## 1️⃣ OpenAI API 키 발급 (5분 소요)

### 단계별 진행

```
┌─────────────────────────────────────────┐
│  1. OpenAI 회원가입                      │
│  https://platform.openai.com/signup     │
│  → 이메일 또는 Google 계정으로 가입      │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  2. API 키 생성                          │
│  https://platform.openai.com/api-keys   │
│  → "Create new secret key" 클릭         │
│  → 키 이름 입력: "LangChain Chatbot"    │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  3. API 키 복사                          │
│  ⚠️ 한 번만 표시되니 꼭 저장!           │
│  형식: sk-proj-xxxxxxxxxxxxx...         │
└─────────────────────────────────────────┘
```

---

## 2️⃣ 환경 변수 설정 (1분 소요)

### 프로젝트 루트의 `.env` 파일 수정

```bash
# 위치: C:\Users\hi\Documents\seoeunjin\langchain\.env
#
# 현재 파일:
# OPENAI_API_KEY=
#
# 수정 후:
OPENAI_API_KEY=sk-proj-여기에_복사한_키를_붙여넣기
```

**예시:**
```bash
OPENAI_API_KEY=sk-proj-abc123def456ghi789jkl012mno345pqr678stu901vwx234yz
```

---

## 3️⃣ 실행 (2분 소요)

### PowerShell에서 실행

```powershell
# 프로젝트 디렉토리로 이동
cd C:\Users\hi\Documents\seoeunjin\langchain

# Docker Compose로 모든 서비스 실행
docker compose up --build
```

### 실행 중 화면

```
✓ postgres   (healthy)
✓ langchain-app (started)
✓ chatbot (started) - http://localhost:3000
```

---

## 4️⃣ 접속 및 테스트

### 브라우저 접속
```
http://localhost:3000
```

### 테스트 메시지
```
"안녕하세요! 자기소개 해주세요"
```

---

## ⚡ 전체 명령어 한 번에

```powershell
# 1. 프로젝트 이동
cd C:\Users\hi\Documents\seoeunjin\langchain

# 2. .env 파일 수정 (메모장으로 열기)
notepad .env

# 3. API 키 입력 후 저장
# OPENAI_API_KEY=sk-proj-여기에_키_입력

# 4. Docker 실행
docker compose up --build

# 5. 브라우저에서 http://localhost:3000 접속
```

---

## ❓ 문제 해결

### "API 키가 없습니다" 메시지가 나올 때
1. `.env` 파일에 API 키가 제대로 입력되었는지 확인
2. 키 앞뒤에 공백이 없는지 확인
3. Docker를 재시작: `docker compose restart chatbot`

### Docker가 실행되지 않을 때
```powershell
# 기존 컨테이너 정리
docker compose down

# 다시 시작
docker compose up --build
```

### 포트가 이미 사용중일 때
```powershell
# 3000번 포트를 사용하는 프로세스 확인
netstat -ano | findstr :3000

# 또는 docker-compose.yaml에서 포트 변경
# ports: "3001:3000"
```

---

## 💡 팁

1. **무료 크레딧**: 신규 가입 시 $5 무료 크레딧 제공
2. **요금**: GPT-3.5-Turbo는 메시지당 약 0.1원 이하
3. **예산 설정**: OpenAI 대시보드에서 월 한도 설정 가능
4. **PWA 설치**: 모바일에서 "홈 화면에 추가"로 앱처럼 사용

---

## 📱 모바일에서 사용

1. 모바일 브라우저에서 `http://컴퓨터IP:3000` 접속
2. 브라우저 메뉴 → "홈 화면에 추가"
3. 앱 아이콘이 생성됨 (PWA)

---

## 다음 단계

- ✅ API 키 발급 완료
- ✅ 환경 변수 설정 완료
- ✅ 앱 실행 완료
- 🎉 챗봇과 대화 시작!

더 자세한 정보는 `SETUP_GUIDE.md`를 참고하세요.

