# EC2 접속 문제 해결 가이드

GitHub Actions 배포가 성공했지만 EC2에 접속이 안 되는 경우, 다음 단계를 순서대로 확인하세요.

## 🔍 단계별 확인 방법

### 1단계: EC2 인스턴스 상태 확인

**AWS 콘솔에서 확인:**
1. AWS 콘솔 → EC2 → Instances
2. 인스턴스 상태가 `running`인지 확인
3. Public IP가 `54.180.101.84`인지 확인

### 2단계: Security Group 설정 확인 (가장 중요!)

**포트 8000이 열려있는지 확인:**

1. AWS 콘솔 → EC2 → Security Groups
2. EC2 인스턴스에 연결된 Security Group 선택
3. **Inbound rules** 탭 확인
4. 포트 8000 규칙이 있는지 확인

**포트 8000 규칙이 없다면 추가:**
- **Edit inbound rules** 클릭
- **Add rule** 클릭
- 설정:
  - **Type**: Custom TCP
  - **Port**: 8000
  - **Source**: `0.0.0.0/0` (모든 IP 허용) 또는 특정 IP
  - **Description**: "FastAPI Application"
- **Save rules** 클릭

### 3단계: EC2에서 서비스 상태 확인

**SSH로 EC2 접속:**
```bash
ssh -i "ESGseed.pem" ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com
```

**서비스 상태 확인:**
```bash
# systemd 서비스 상태 확인
sudo systemctl status rag-fastapi

# 실행 중이 아니면 시작
sudo systemctl start rag-fastapi

# 서비스 로그 확인
sudo journalctl -u rag-fastapi -n 100 --no-pager
```

**예상되는 정상 상태:**
```
● rag-fastapi.service - RAG FastAPI Application
   Loaded: loaded (/etc/systemd/system/rag-fastapi.service; enabled)
   Active: active (running) since ...
```

### 4단계: 포트 리스닝 확인

**EC2에서 실행:**
```bash
# 포트 8000이 리스닝 중인지 확인
sudo netstat -tlnp | grep 8000
# 또는
sudo ss -tlnp | grep 8000
```

**예상 출력:**
```
tcp  0  0  0.0.0.0:8000  0.0.0.0:*  LISTEN  12345/python
```

**포트가 리스닝되지 않으면:**
- 서비스가 실행되지 않았거나
- 에러로 인해 시작되지 않았을 수 있음
- 로그 확인 필요

### 5단계: 방화벽(UFW) 확인

**EC2에서 실행:**
```bash
# UFW 상태 확인
sudo ufw status

# 포트 8000이 허용되어 있는지 확인
# 허용되어 있지 않으면:
sudo ufw allow 8000/tcp
sudo ufw reload
```

### 6단계: 로컬에서 연결 테스트

**EC2에서 실행:**
```bash
# localhost에서 테스트
curl http://localhost:8000/api/v1/health

# 정상 응답 예시:
# {"status":"healthy","vector_store_initialized":true}
```

**성공하면:** 서비스는 정상, Security Group 문제
**실패하면:** 서비스 문제, 로그 확인 필요

### 7단계: 서비스 로그 확인

**EC2에서 실행:**
```bash
# 최근 로그 확인
sudo journalctl -u rag-fastapi -n 100 --no-pager

# 실시간 로그 확인
sudo journalctl -u rag-fastapi -f
```

**일반적인 에러:**
- 모듈을 찾을 수 없음 → 의존성 설치 문제
- 포트가 이미 사용 중 → 다른 프로세스가 포트 사용 중
- 데이터베이스 연결 실패 → 환경 변수 문제

## 🚨 빠른 해결 체크리스트

- [ ] Security Group에서 포트 8000 허용 확인
- [ ] EC2 인스턴스가 running 상태인지 확인
- [ ] 서비스가 실행 중인지 확인: `sudo systemctl status rag-fastapi`
- [ ] 포트가 리스닝 중인지 확인: `sudo netstat -tlnp | grep 8000`
- [ ] UFW 방화벽에서 포트 8000 허용 확인
- [ ] 로컬에서 연결 테스트: `curl http://localhost:8000/api/v1/health`
- [ ] 서비스 로그 확인: `sudo journalctl -u rag-fastapi -n 100`

## 🔧 일반적인 문제 해결

### 문제 1: Security Group 포트 미개방

**해결:**
1. AWS 콘솔 → EC2 → Security Groups
2. Inbound rules에 포트 8000 추가

### 문제 2: 서비스가 실행되지 않음

**해결:**
```bash
# 서비스 시작
sudo systemctl start rag-fastapi

# 자동 시작 설정
sudo systemctl enable rag-fastapi

# 상태 확인
sudo systemctl status rag-fastapi
```

### 문제 3: 의존성 설치 실패

**해결:**
```bash
cd /home/ubuntu/rag-app
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart rag-fastapi
```

### 문제 4: 환경 변수 문제

**해결:**
```bash
# .env 파일 확인
cat /home/ubuntu/rag-app/.env

# 환경 변수가 올바른지 확인
# POSTGRES_CONNECTION_STRING이 설정되어 있는지 확인
```

### 문제 5: 포트 충돌

**해결:**
```bash
# 포트를 사용하는 프로세스 확인
sudo lsof -i :8000

# 프로세스 종료 (필요시)
sudo kill -9 <PID>
```

## 📝 디버깅 명령어 모음

```bash
# 서비스 상태
sudo systemctl status rag-fastapi

# 서비스 시작
sudo systemctl start rag-fastapi

# 서비스 중지
sudo systemctl stop rag-fastapi

# 서비스 재시작
sudo systemctl restart rag-fastapi

# 로그 확인
sudo journalctl -u rag-fastapi -n 100 --no-pager
sudo journalctl -u rag-fastapi -f

# 포트 확인
sudo netstat -tlnp | grep 8000
sudo ss -tlnp | grep 8000

# 방화벽 확인
sudo ufw status

# 로컬 연결 테스트
curl http://localhost:8000/api/v1/health
curl http://localhost:8000/

# 프로세스 확인
ps aux | grep uvicorn
ps aux | grep python
```

## ✅ 정상 작동 확인

모든 단계를 통과하면 다음이 가능해야 합니다:

1. **로컬 테스트:**
   ```bash
   curl http://localhost:8000/api/v1/health
   ```

2. **외부 접속:**
   - 브라우저: `http://54.180.101.84:8000/docs`
   - API: `http://54.180.101.84:8000/api/v1/health`

## 🆘 여전히 해결되지 않으면

1. GitHub Actions 로그 확인
2. EC2 서비스 로그 확인
3. Security Group 설정 재확인
4. EC2 인스턴스 재시작 시도

