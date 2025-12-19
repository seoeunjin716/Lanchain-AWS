# EC2 배포 문제 해결 가이드

## SSH 연결 타임아웃 에러

### 에러 메시지
```
ssh: connect to host *** port 22: Connection timed out
rsync: connection unexpectedly closed
```

### 원인 및 해결 방법

#### 1. EC2 인스턴스 상태 확인

**확인 방법:**
```bash
# AWS 콘솔에서 확인
# 또는 AWS CLI 사용
aws ec2 describe-instances --instance-ids <instance-id>
```

**해결:**
- 인스턴스가 `stopped` 상태면 `running`으로 시작
- 인스턴스가 `terminated` 상태면 새 인스턴스 생성 필요

#### 2. Security Group 설정 확인

**문제:** Security Group에서 포트 22(SSH)가 GitHub Actions IP에서 접근 불가

**해결 방법:**

**옵션 A: 모든 IP 허용 (개발/테스트용)**
1. AWS 콘솔 → EC2 → Security Groups
2. 해당 Security Group 선택
3. Inbound rules → Edit inbound rules
4. SSH (22) 규칙 추가:
   - Type: SSH
   - Port: 22
   - Source: `0.0.0.0/0` (모든 IP 허용)
   - Description: "Allow SSH from GitHub Actions"

**옵션 B: GitHub Actions IP만 허용 (프로덕션 권장)**
GitHub Actions IP 범위를 확인하고 허용:
- GitHub Actions IP 범위는 동적으로 변경될 수 있음
- [GitHub Actions IP 범위 문서](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#ip-addresses) 참고

**옵션 C: 현재 IP만 허용 (임시 테스트)**
1. 로컬에서 현재 IP 확인:
   ```bash
   curl ifconfig.me
   ```
2. Security Group에 해당 IP 추가

#### 3. EC2 Public IP/DNS 확인

**문제:** EC2 인스턴스 재시작 시 Public IP가 변경될 수 있음

**확인 방법:**
```bash
# AWS 콘솔에서 확인
# 또는 AWS CLI
aws ec2 describe-instances --instance-ids <instance-id> --query 'Reservations[0].Instances[0].PublicDnsName'
```

**해결:**
- GitHub Secrets의 `EC2_HOST`를 최신 Public DNS로 업데이트
- 또는 Elastic IP를 할당하여 고정 IP 사용

#### 4. 네트워크 ACL 확인

**확인 방법:**
1. AWS 콘솔 → VPC → Network ACLs
2. EC2 인스턴스가 속한 서브넷의 Network ACL 확인
3. Inbound/Outbound 규칙에서 포트 22 허용 확인

#### 5. 로컬에서 직접 연결 테스트

**테스트 방법:**
```bash
# 로컬에서 SSH 연결 테스트
ssh -i "ESGseed.pem" -v ubuntu@ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com
```

**성공하면:** GitHub Actions 설정 문제
**실패하면:** EC2 인스턴스 또는 네트워크 설정 문제

## 일반적인 문제 해결 체크리스트

### 배포 전 확인사항

- [ ] EC2 인스턴스가 `running` 상태인가?
- [ ] Security Group에서 포트 22(SSH)가 허용되어 있는가?
- [ ] GitHub Secrets의 `EC2_HOST`가 올바른가?
- [ ] GitHub Secrets의 `EC2_SSH_KEY`가 올바른가?
- [ ] 로컬에서 SSH 연결이 가능한가?

### 배포 중 에러

#### "Connection timed out"
→ Security Group 또는 네트워크 설정 문제

#### "Permission denied (publickey)"
→ `EC2_SSH_KEY` secret이 잘못되었거나 키 형식 문제

#### "Host key verification failed"
→ known_hosts 문제 (워크플로우에서 자동 처리됨)

#### "rsync: connection unexpectedly closed"
→ SSH 연결은 되지만 중간에 끊김 (네트워크 불안정 또는 타임아웃)

## 빠른 해결 방법

### 1. Security Group 즉시 수정

```bash
# AWS CLI 사용 (선택사항)
aws ec2 authorize-security-group-ingress \
  --group-id <security-group-id> \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

### 2. EC2 인스턴스 재시작

```bash
# AWS 콘솔에서 또는 CLI
aws ec2 start-instances --instance-ids <instance-id>
```

### 3. GitHub Secrets 재확인

1. Repository → Settings → Secrets and variables → Actions
2. 다음 secrets 확인:
   - `EC2_HOST`: `ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com`
   - `EC2_USER`: `ubuntu`
   - `EC2_SSH_KEY`: SSH 개인키 전체 내용

## 추가 디버깅

### GitHub Actions 로그 확인

1. Repository → Actions → 실패한 워크플로우
2. "Deploy to EC2" 단계 클릭
3. 에러 메시지 확인

### EC2에서 직접 확인

```bash
# EC2에 SSH 접속 후
sudo systemctl status ssh
sudo netstat -tlnp | grep 22
```

### 네트워크 연결 테스트

```bash
# GitHub Actions runner에서 (로컬 테스트 불가)
ping <EC2_HOST>
telnet <EC2_HOST> 22
```

## 예방 조치

1. **Elastic IP 사용**: Public IP 고정
2. **Security Group 최소 권한**: 필요한 IP만 허용
3. **연결 재시도 로직**: 워크플로우에 포함됨
4. **모니터링 설정**: CloudWatch로 인스턴스 상태 모니터링

