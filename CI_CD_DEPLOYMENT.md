# FastAPI EC2 CI/CD 배포 가이드

이 문서는 GitHub Actions를 사용하여 FastAPI 애플리케이션을 EC2에 자동 배포하는 방법을 설명합니다.

## 📋 사전 준비

### 1. EC2 인스턴스 정보 확인

SSH 명령어에서 다음 정보를 추출했습니다:

- **EC2_HOST**: `ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com`
- **EC2_USER**: `ubuntu`

### 2. GitHub Secrets 설정

GitHub Repository → Settings → Secrets and variables → Actions에서 다음 secrets를 설정하세요:

| Secret 이름 | 값 | 설명 |
|------------|-----|------|
| `EC2_HOST` | `ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com` | EC2 Public DNS |
| `EC2_USER` | `ubuntu` | EC2 사용자명 |
| `EC2_SSH_KEY` | `-----BEGIN RSA PRIVATE KEY-----...` | SSH 개인키 전체 내용 |
| `POSTGRES_CONNECTION_STRING` | `postgresql://...` | PostgreSQL 연결 문자열 |
| `OPENAI_API_KEY` | `sk-...` | OpenAI API 키 (선택사항) |

#### SSH 키 가져오기 방법

**Windows (PowerShell):**
```powershell
Get-Content ESGseed.pem | Set-Clipboard
```

**Mac/Linux:**
```bash
cat ESGseed.pem | pbcopy
```

그 다음 GitHub Secrets의 `EC2_SSH_KEY`에 붙여넣기하세요.

### 3. EC2 초기 설정 (최초 1회만)

EC2에 SSH 접속 후 초기 설정 스크립트를 실행하세요:

```bash
# EC2에 SSH 접속
ssh -i "ESGseed.pem" ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com

# 프로젝트 디렉토리 생성
mkdir -p ~/app
cd ~/app

# 초기 설정 스크립트 다운로드 및 실행
wget https://raw.githubusercontent.com/seoeunjin716/Lanchain-AWS/main/scripts/setup-ec2-direct.sh
chmod +x setup-ec2-direct.sh
./setup-ec2-direct.sh
```

또는 로컬에서 스크립트를 직접 전송:

```bash
# 로컬에서 실행
scp -i "ESGseed.pem" scripts/setup-ec2-direct.sh ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com:~/
ssh -i "ESGseed.pem" ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com "chmod +x ~/setup-ec2-direct.sh && ~/setup-ec2-direct.sh"
```

### 4. 모델 파일 업로드 (필요한 경우)

모델 파일이 필요한 경우 EC2에 업로드하세요:

```bash
# 로컬에서 실행
scp -i "ESGseed.pem" -r backend/app/models/midm/ ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com:~/app/backend/app/models/
```

## 🚀 CI/CD 배포 프로세스

### 자동 배포 (권장)

`main` 브랜치에 코드를 push하면 자동으로 배포가 시작됩니다:

```bash
git add .
git commit -m "Deploy to EC2"
git push origin main
```

### 수동 배포

GitHub Actions 탭에서 `Deploy to EC2` 워크플로우를 선택하고 `Run workflow` 버튼을 클릭하세요.

## 📊 배포 프로세스 상세 설명

### 1. GitHub Actions 워크플로우 실행

`.github/workflows/deploy-ec2.yml` 파일이 다음 단계를 실행합니다:

1. **코드 체크아웃**: GitHub 저장소에서 최신 코드를 가져옵니다.
2. **SSH 설정**: EC2에 접속하기 위한 SSH 키를 설정합니다.
3. **코드 동기화**: `rsync`를 사용하여 코드를 EC2에 동기화합니다.
   - 제외되는 항목: `node_modules/`, `.git/`, `__pycache__/`, `.venv/`, `.env` 등
4. **배포 스크립트 실행**: EC2에서 배포 스크립트를 실행합니다.

### 2. EC2에서의 배포 과정

배포 스크립트는 다음 작업을 수행합니다:

1. **환경 변수 설정**: `.env` 파일 생성
2. **Python 가상환경 생성**: `venv` 디렉토리에 가상환경 생성
3. **의존성 설치**: `requirements.txt`의 패키지 설치
4. **systemd 서비스 생성**: FastAPI를 systemd 서비스로 등록
5. **서비스 시작**: systemd를 통해 FastAPI 서버 시작
6. **헬스 체크**: `/api/v1/health` 엔드포인트로 서비스 상태 확인

### 3. systemd 서비스 관리

배포 후 EC2에서 서비스를 관리할 수 있습니다:

```bash
# 서비스 상태 확인
sudo systemctl status rag-fastapi

# 서비스 시작
sudo systemctl start rag-fastapi

# 서비스 중지
sudo systemctl stop rag-fastapi

# 서비스 재시작
sudo systemctl restart rag-fastapi

# 서비스 로그 확인
sudo journalctl -u rag-fastapi -f

# 최근 100줄 로그 확인
sudo journalctl -u rag-fastapi -n 100
```

## 🔍 배포 상태 확인

### 1. GitHub Actions에서 확인

GitHub Repository → Actions 탭에서 배포 진행 상황을 확인할 수 있습니다.

### 2. EC2에서 직접 확인

```bash
# 서비스 상태
sudo systemctl status rag-fastapi

# 헬스 체크
curl http://localhost:8000/api/v1/health

# API 문서 접속
# 브라우저에서: http://ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com:8000/docs
```

### 3. 외부에서 접속 확인

브라우저에서 다음 URL로 접속:

- **API 문서**: `http://ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com:8000/docs`
- **헬스 체크**: `http://ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com:8000/api/v1/health`
- **루트 엔드포인트**: `http://ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com:8000/`

## 🔄 롤백 방법

### 방법 1: GitHub에서 이전 커밋으로 롤백

```bash
# 로컬에서 이전 커밋으로 되돌리기
git revert HEAD
git push origin main
```

### 방법 2: EC2에서 직접 수정

```bash
# EC2에 SSH 접속
ssh -i "ESGseed.pem" ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com

# 이전 버전으로 체크아웃
cd ~/app
git checkout <previous-commit-hash>

# 서비스 재시작
sudo systemctl restart rag-fastapi
```

## ⚠️ 주의사항

1. **보안 그룹 설정**: EC2 Security Group에서 포트 8000이 열려있는지 확인하세요.
2. **환경 변수**: `.env` 파일은 Git에 포함되지 않으며, GitHub Secrets에서 관리됩니다.
3. **모델 파일**: 대용량 모델 파일은 Git에 포함되지 않으므로 별도로 업로드해야 합니다.
4. **디스크 공간**: 모델 파일과 Python 패키지 설치를 위한 충분한 디스크 공간을 확보하세요.
5. **방화벽**: UFW 방화벽이 활성화되어 있으면 포트 8000이 허용되어 있는지 확인하세요.

## 🐛 문제 해결

### 배포 실패 시

1. **GitHub Actions 로그 확인**
   - Repository → Actions → 실패한 워크플로우 클릭
   - 각 단계의 로그를 확인하여 오류 원인 파악

2. **EC2에서 직접 확인**
   ```bash
   # 서비스 로그 확인
   sudo journalctl -u rag-fastapi -n 100 --no-pager

   # 서비스 상태 확인
   sudo systemctl status rag-fastapi

   # 수동으로 서비스 시작 시도
   cd ~/app
   source venv/bin/activate
   uvicorn backend.app.main:app --host 0.0.0.0 --port 8000
   ```

3. **헬스 체크 실패 시**
   ```bash
   # 포트 사용 확인
   sudo netstat -tlnp | grep 8000

   # 프로세스 확인
   ps aux | grep uvicorn
   ```

### 의존성 설치 실패 시

```bash
# EC2에 SSH 접속 후
cd ~/app
source venv/bin/activate
pip install --upgrade pip
pip install -r backend/requirements.txt
```

### 모델 로드 실패 시

```bash
# 모델 파일 존재 확인
ls -lh ~/app/backend/app/models/midm/

# 권한 확인 및 수정
chmod -R 755 ~/app/backend/app/models/midm/
```

## 📝 추가 설정 (선택사항)

### Nginx 리버스 프록시 설정

프로덕션 환경에서는 Nginx를 사용하여 HTTPS 및 도메인 연결을 권장합니다.

### 모니터링 설정

CloudWatch나 Prometheus를 사용하여 애플리케이션 모니터링을 설정할 수 있습니다.

### 로그 관리

systemd journal의 로그 크기 제한을 설정하여 디스크 공간을 관리할 수 있습니다.

## ✅ 배포 체크리스트

배포 전 확인사항:

- [ ] GitHub Secrets 설정 완료 (EC2_HOST, EC2_USER, EC2_SSH_KEY, POSTGRES_CONNECTION_STRING)
- [ ] EC2 초기 설정 완료 (`setup-ec2-direct.sh` 실행)
- [ ] EC2 Security Group에서 포트 8000 허용
- [ ] 모델 파일 업로드 완료 (필요한 경우)
- [ ] `.env` 파일에 필요한 환경 변수 설정
- [ ] `requirements.txt`에 모든 의존성 포함
- [ ] 코드가 `main` 브랜치에 push됨

배포 후 확인사항:

- [ ] GitHub Actions 워크플로우 성공
- [ ] EC2에서 서비스 상태 정상 (`sudo systemctl status rag-fastapi`)
- [ ] 헬스 체크 통과 (`curl http://localhost:8000/api/v1/health`)
- [ ] API 문서 접속 가능 (`http://EC2_HOST:8000/docs`)

