# SSH 키 형식 오류 해결 가이드

에러: `Error loading key "(stdin)": error in libcrypto`

이것은 GitHub Secrets의 `EC2_SSH_KEY`가 올바른 형식이 아니라는 의미입니다.

## 🔍 문제 원인

SSH 키가 다음 중 하나일 수 있습니다:
1. 키 형식이 잘못됨
2. 복사/붙여넣기 과정에서 줄바꿈이 손상됨
3. 키가 불완전함 (일부만 복사됨)
4. 잘못된 키 파일

## ✅ 해결 방법

### 1. SSH 키 파일 확인

로컬에서 SSH 키 파일을 확인:

```bash
# Windows PowerShell
Get-Content ESGseed.pem

# 또는 메모장으로 열기
notepad ESGseed.pem
```

**올바른 형식:**
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
(여러 줄의 키 내용)
...
-----END RSA PRIVATE KEY-----
```

또는

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAA...
(여러 줄의 키 내용)
...
-----END OPENSSH PRIVATE KEY-----
```

### 2. SSH 키 전체 내용 복사

**Windows PowerShell에서:**

```powershell
# 방법 1: 전체 내용 복사
Get-Content ESGseed.pem -Raw | Set-Clipboard

# 방법 2: 파일 내용 확인 후 수동 복사
Get-Content ESGseed.pem
```

**중요 사항:**
- `-----BEGIN`부터 `-----END`까지 전체를 복사해야 합니다
- 줄바꿈이 포함되어야 합니다
- 앞뒤 공백이나 추가 텍스트가 없어야 합니다

### 3. GitHub Secrets에 다시 설정

1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. `EC2_SSH_KEY` 선택 (또는 "New repository secret" 클릭)
3. **Value** 필드에 SSH 키 전체 내용 붙여넣기
   - `-----BEGIN`부터 `-----END`까지 전체
   - 줄바꿈 포함
4. "Update secret" (또는 "Add secret") 클릭

### 4. SSH 키 형식 검증

로컬에서 키가 유효한지 확인:

```bash
# Windows PowerShell
ssh-keygen -l -f ESGseed.pem

# 또는 SSH 연결 테스트
ssh -i ESGseed.pem ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com
```

로컬에서 연결이 안 되면 키 자체에 문제가 있을 수 있습니다.

## 🔧 단계별 해결

### Step 1: SSH 키 파일 열기

```powershell
# PowerShell에서
notepad ESGseed.pem
```

### Step 2: 전체 내용 선택 및 복사

- `Ctrl+A` (전체 선택)
- `Ctrl+C` (복사)
- `-----BEGIN`부터 `-----END`까지 모든 내용 포함

### Step 3: GitHub Secrets 업데이트

1. GitHub → Settings → Secrets → Actions
2. `EC2_SSH_KEY` 클릭 (또는 새로 생성)
3. Value 필드에 붙여넣기 (`Ctrl+V`)
4. "Update secret" 클릭

### Step 4: GitHub Actions 재실행

1. Actions → "Deploy to EC2"
2. "Run workflow" 클릭
3. main 브랜치 선택 후 실행

## ⚠️ 주의사항

1. **줄바꿈 보존**: 키를 복사할 때 줄바꿈이 유지되어야 합니다
2. **전체 내용**: `-----BEGIN`부터 `-----END`까지 모두 포함
3. **공백 제거**: 앞뒤 불필요한 공백이나 텍스트 제거
4. **인코딩**: UTF-8 인코딩 사용

## 🧪 테스트 방법

로컬에서 SSH 키가 작동하는지 먼저 테스트:

```bash
ssh -i ESGseed.pem ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com
```

- **성공하면**: 키는 정상, GitHub Secrets 설정 문제
- **실패하면**: 키 자체에 문제가 있거나 EC2 인스턴스 문제

## 💡 빠른 해결

1. `ESGseed.pem` 파일을 메모장으로 열기
2. 전체 내용 복사 (`Ctrl+A`, `Ctrl+C`)
3. GitHub Secrets의 `EC2_SSH_KEY`에 붙여넣기
4. "Update secret" 클릭
5. GitHub Actions 재실행

