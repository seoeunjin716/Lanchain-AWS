# SSH 연결 타임아웃 해결 가이드

GitHub Actions에서 EC2로 SSH 연결이 실패하는 경우 해결 방법입니다.

## 🔍 문제 진단

에러 메시지: `ssh: connect to host *** port 22: Connection timed out`

이것은 GitHub Actions가 EC2 인스턴스의 포트 22(SSH)에 접근할 수 없다는 의미입니다.

## ✅ 해결 방법

### 1단계: Security Group에서 포트 22 확인

**AWS 콘솔에서 확인:**

1. AWS 콘솔 → EC2 → Security Groups
2. EC2 인스턴스에 연결된 Security Group 선택
3. **Inbound rules** 탭 확인
4. **포트 22(SSH) 규칙이 있는지 확인**

**포트 22 규칙이 없다면 추가:**

- **Edit inbound rules** 클릭
- **Add rule** 클릭
- 설정:
  - **Type**: SSH
  - **Port**: 22
  - **Source**: `0.0.0.0/0` (모든 IP 허용) 또는 GitHub Actions IP 범위
  - **Description**: "Allow SSH from GitHub Actions"
- **Save rules** 클릭

**중요:** "모든 트래픽" 규칙이 있어도, 명시적으로 SSH 규칙이 있는지 확인하세요.

### 2단계: EC2 인스턴스 상태 확인

**AWS 콘솔에서 확인:**

1. AWS 콘솔 → EC2 → Instances
2. 인스턴스 상태가 `running`인지 확인
3. Public IP가 올바른지 확인

### 3단계: GitHub Secrets 확인

**GitHub 저장소 → Settings → Secrets and variables → Actions에서 확인:**

- `EC2_HOST`: `ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com` (또는 Public IP)
- `EC2_USER`: `ubuntu`
- `EC2_SSH_KEY`: SSH 개인키 전체 내용

**EC2_HOST 확인 방법:**

```bash
# AWS 콘솔에서 EC2 인스턴스의 Public DNS 확인
# 또는 Public IP 사용: 54.180.101.84
```

### 4단계: 로컬에서 SSH 연결 테스트

**로컬 컴퓨터에서 테스트:**

```bash
ssh -i "ESGseed.pem" ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com
```

- **성공하면**: Security Group은 정상, GitHub Actions 설정 문제
- **실패하면**: Security Group 또는 EC2 인스턴스 문제

## 🚨 빠른 해결 체크리스트

- [ ] Security Group Inbound rules에 SSH (포트 22) 규칙 추가
- [ ] Source를 `0.0.0.0/0`로 설정 (또는 GitHub Actions IP 범위)
- [ ] EC2 인스턴스가 `running` 상태인지 확인
- [ ] GitHub Secrets의 `EC2_HOST`가 올바른지 확인
- [ ] 로컬에서 SSH 연결이 되는지 테스트

## 📝 Security Group 설정 예시

**Inbound Rules:**
1. SSH (22) - Source: `0.0.0.0/0` - Description: "Allow SSH"
2. Custom TCP (8000) - Source: `0.0.0.0/0` - Description: "FastAPI"
3. HTTPS (443) - Source: `0.0.0.0/0` - Description: "HTTPS"

## 🔧 추가 확인 사항

### GitHub Actions IP 범위 (선택사항)

GitHub Actions IP는 동적으로 변경될 수 있으므로, 보안을 위해 특정 IP만 허용하려면:
- [GitHub Actions IP 범위 문서](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#ip-addresses) 참고
- 하지만 개발/테스트 환경에서는 `0.0.0.0/0` 사용이 더 간단합니다

### EC2 인스턴스 재시작

Security Group을 수정한 후에도 연결이 안 되면:
1. EC2 인스턴스 재시작 시도
2. Public IP가 변경되었는지 확인 (Elastic IP 사용 권장)

## ✅ 확인 후 재시도

Security Group 설정을 완료한 후:

1. GitHub Actions → "Deploy to EC2" 워크플로우
2. "Run workflow" 버튼 클릭
3. main 브랜치 선택 후 실행

