# EC2 배포 가이드

이 문서는 GitHub Actions를 통한 EC2 자동 배포 설정 방법을 설명합니다.

## 📋 사전 준비

### 1. EC2 인스턴스 생성

- **Instance Type**: t3.xlarge 이상 (모델 로딩을 위한 메모리 필요)
- **Storage**: 최소 30GB
- **OS**: Ubuntu 22.04 LTS
- **Security Group**: 22 (SSH), 8000 (Backend API)

### 2. EC2 초기 설정

EC2에 SSH 접속 후 다음 명령어 실행:

```bash
# 초기 설정 스크립트 다운로드 및 실행
wget https://raw.githubusercontent.com/your-repo/main/scripts/setup-ec2.sh
chmod +x setup-ec2.sh
./setup-ec2.sh

# Docker 그룹 적용을 위해 재로그인
exit
# 다시 SSH 접속
```

### 3. 모델 파일 업로드

모델 파일(4.3GB)은 Git에 포함되지 않으므로 EC2에 직접 업로드해야 합니다.

#### 방법 A: SCP 사용 (로컬에서)

```bash
# 로컬에서 실행
scp -i your-key.pem -r backend/app/models/midm/ ubuntu@your-ec2-ip:~/app/backend/app/models/
```

#### 방법 B: S3 사용 (권장)

```bash
# 로컬에서 S3에 업로드 (1회만)
aws s3 cp backend/app/models/midm/ s3://your-bucket/models/midm/ --recursive

# EC2에서 S3에서 다운로드
aws s3 sync s3://your-bucket/models/midm/ ~/app/backend/app/models/midm/
```

### 4. 환경 변수 설정

EC2에서 `.env` 파일 편집:

```bash
cd ~/app
nano .env
```

`.env` 파일 내용:

```env
POSTGRES_CONNECTION_STRING=postgresql://...
OPENAI_API_KEY=sk-...
```

## 🔐 GitHub Secrets 설정

GitHub Repository → Settings → Secrets and variables → Actions → New repository secret

다음 secrets를 추가:

| Secret 이름 | 설명 | 예시 |
|------------|------|------|
| `EC2_HOST` | EC2 Public IP 또는 DNS | `ec2-xx-xx-xx-xx.compute.amazonaws.com` |
| `EC2_USER` | EC2 사용자명 | `ubuntu` |
| `EC2_SSH_KEY` | EC2 SSH 개인키 전체 내용 | `-----BEGIN RSA PRIVATE KEY-----...` |
| `POSTGRES_CONNECTION_STRING` | PostgreSQL 연결 문자열 | `postgresql://...` |
| `OPENAI_API_KEY` | OpenAI API 키 | `sk-...` |

### SSH 키 가져오기

```bash
# Windows (PowerShell)
Get-Content ~/.ssh/id_rsa | Set-Clipboard

# Mac/Linux
cat ~/.ssh/id_rsa | pbcopy
```

## 🚀 배포 프로세스

### 자동 배포

`main` 브랜치에 push하면 자동으로 배포됩니다:

```bash
git push origin main
```

### 수동 배포

GitHub Actions 탭에서 `Deploy to EC2` 워크플로우를 선택하고 `Run workflow` 클릭

### EC2에서 직접 배포

```bash
# EC2에 SSH 접속 후
cd ~/app
bash scripts/deploy.sh
```

## 📊 배포 상태 확인

### 로그 확인

```bash
# EC2에서
docker-compose -f docker-compose.prod.yaml logs -f
```

### 헬스 체크

```bash
curl http://localhost:8000/api/v1/health
```

### API 문서

브라우저에서 접속: `http://your-ec2-ip:8000/docs`

## 🔄 롤백

이전 버전으로 롤백하려면:

```bash
# EC2에서
cd ~/app
git checkout <previous-commit-hash>
docker-compose -f docker-compose.prod.yaml down
docker-compose -f docker-compose.prod.yaml up -d --build
```

## ⚠️ 주의사항

1. **모델 파일**: 모델 파일은 Git에 포함되지 않으므로 EC2에 별도로 업로드해야 합니다.
2. **환경 변수**: `.env` 파일은 Git에 포함되지 않습니다. GitHub Secrets로 관리하세요.
3. **디스크 공간**: 모델 파일(4.3GB)과 Docker 이미지 공간을 고려하세요.
4. **보안**: Production 환경에서는 HTTPS 및 방화벽 설정을 권장합니다.

## 🐛 문제 해결

### 배포 실패 시

1. GitHub Actions 로그 확인
2. EC2에서 직접 로그 확인:
   ```bash
   docker-compose -f docker-compose.prod.yaml logs
   ```
3. 헬스 체크 확인:
   ```bash
   curl http://localhost:8000/api/v1/health
   ```

### 모델 로드 실패 시

```bash
# 모델 파일 존재 확인
ls -lh ~/app/backend/app/models/midm/

# 권한 확인
chmod -R 755 ~/app/backend/app/models/midm/
```

## 📝 추가 설정 (선택사항)

### Nginx 리버스 프록시

프로덕션 환경에서는 Nginx를 사용하여 HTTPS 및 도메인 연결을 권장합니다.

### 모니터링

CloudWatch나 Prometheus를 사용하여 모니터링을 설정할 수 있습니다.

