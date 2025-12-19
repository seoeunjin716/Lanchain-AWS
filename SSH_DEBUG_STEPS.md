# SSH 연결 실패 추가 디버깅 단계

Security Group을 설정했는데도 SSH 연결이 실패하는 경우 확인할 사항입니다.

## 🔍 즉시 확인할 사항

### 1. Security Group이 EC2 인스턴스에 연결되어 있는지 확인

**중요:** Security Group 규칙을 추가했지만, 해당 Security Group이 EC2 인스턴스에 연결되어 있지 않을 수 있습니다.

**확인 방법:**
1. AWS 콘솔 → EC2 → Instances
2. EC2 인스턴스 선택
3. 하단 "Security" 탭 클릭
4. "Security groups" 섹션 확인
5. Security Group 이름이 `launch-wizard-1` (sg-03b5588f655f1314e)인지 확인

**다른 Security Group이 연결되어 있다면:**
- 해당 Security Group에도 SSH 규칙을 추가하거나
- EC2 인스턴스의 Security Group을 변경해야 합니다

### 2. EC2 인스턴스 상태 확인

1. AWS 콘솔 → EC2 → Instances
2. 인스턴스 상태가 `running`인지 확인
3. 상태가 `stopped`이면 시작해야 합니다

### 3. Public IP/DNS 확인

1. EC2 인스턴스 선택
2. "Public IPv4 address" 또는 "Public IPv4 DNS" 확인
3. GitHub Secrets의 `EC2_HOST`와 일치하는지 확인

**GitHub Secrets 확인:**
- Repository → Settings → Secrets and variables → Actions
- `EC2_HOST` 값 확인
- `ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com` 또는 `54.180.101.84`와 일치하는지 확인

### 4. 로컬에서 SSH 연결 테스트

**로컬 컴퓨터에서:**

```bash
ssh -i "ESGseed.pem" ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com
```

- **성공하면**: Security Group은 정상, GitHub Actions 설정 문제
- **실패하면**: Security Group 또는 EC2 인스턴스 문제

### 5. Security Group 규칙 재확인

**인바운드 규칙에 다음이 있는지 확인:**

1. SSH (22) - Source: `0.0.0.0/0`
2. Custom TCP (8000) - Source: `0.0.0.0/0` (또는 모든 TCP 규칙)

**규칙이 있다면:**
- "규칙 저장" 버튼을 클릭했는지 확인
- 저장 후 몇 초 기다렸다가 다시 시도

### 6. EC2 인스턴스 재시작 (선택사항)

Security Group을 변경한 후에도 연결이 안 되면:

1. EC2 인스턴스 선택
2. "Instance state" → "Reboot instance"
3. 재시작 후 다시 시도

## 🚨 가장 가능성 높은 원인

### 원인 1: Security Group이 인스턴스에 연결되지 않음

EC2 인스턴스가 다른 Security Group을 사용하고 있을 수 있습니다.

**해결:**
1. EC2 인스턴스 → Security 탭
2. 현재 연결된 Security Group 확인
3. 해당 Security Group에 SSH 규칙 추가

### 원인 2: EC2_HOST secret이 잘못됨

GitHub Secrets의 `EC2_HOST`가 올바르지 않을 수 있습니다.

**확인:**
- AWS 콘솔에서 EC2 인스턴스의 Public DNS 확인
- GitHub Secrets의 `EC2_HOST`와 비교

### 원인 3: EC2 인스턴스가 중지됨

인스턴스가 `stopped` 상태일 수 있습니다.

**해결:**
- 인스턴스 시작

## ✅ 빠른 체크리스트

- [ ] EC2 인스턴스가 `running` 상태인지 확인
- [ ] Security Group이 EC2 인스턴스에 연결되어 있는지 확인
- [ ] 연결된 Security Group의 인바운드 규칙에 SSH (22)가 있는지 확인
- [ ] "규칙 저장" 버튼을 클릭했는지 확인
- [ ] GitHub Secrets의 `EC2_HOST`가 올바른지 확인
- [ ] 로컬에서 SSH 연결이 되는지 테스트

## 🔧 추가 디버깅

### EC2 인스턴스의 Security Group 확인 (명령어)

EC2에 다른 방법으로 접속할 수 있다면:

```bash
# 현재 연결된 Security Group 확인
curl http://169.254.169.254/latest/meta-data/security-groups
```

### Network ACL 확인

VPC를 사용하는 경우 Network ACL도 확인:

1. AWS 콘솔 → VPC → Network ACLs
2. EC2 인스턴스가 속한 서브넷의 Network ACL 확인
3. 인바운드 규칙에서 포트 22 허용 확인

## 💡 해결 방법

가장 빠른 해결책:

1. **EC2 인스턴스 → Security 탭에서 연결된 Security Group 확인**
2. **해당 Security Group에 SSH (22) 규칙 추가**
3. **"규칙 저장" 클릭**
4. **GitHub Actions 재실행**

