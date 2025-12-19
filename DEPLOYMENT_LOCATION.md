# EC2 배포 위치 전략 가이드

FastAPI 애플리케이션을 EC2에 배포할 때 최적의 디렉토리 위치를 선택하는 가이드입니다.

## 📍 배포 위치 옵션 비교

### 1. `/opt/rag-app` (⭐ **권장 - 프로덕션**)

**장점:**
- ✅ Linux FHS (Filesystem Hierarchy Standard) 준수
- ✅ 서드파티 소프트웨어용 표준 위치
- ✅ 시스템 업데이트와 분리되어 안전
- ✅ 권한 관리가 명확함
- ✅ 백업 및 관리가 용이
- ✅ 여러 버전 관리 가능 (`/opt/rag-app-v1`, `/opt/rag-app-v2`)

**단점:**
- ⚠️ sudo 권한 필요 (하지만 systemd 서비스는 이미 sudo 사용)

**사용 시나리오:**
- 프로덕션 환경
- 장기 운영이 필요한 서비스
- 표준화된 배포 전략

### 2. `/srv/rag-app` (대안)

**장점:**
- ✅ 서비스 데이터용 표준 위치
- ✅ FHS 준수

**단점:**
- ⚠️ 일반적으로 데이터 저장용으로 사용
- ⚠️ 애플리케이션 코드보다는 데이터에 적합

**사용 시나리오:**
- 서비스별 데이터 저장이 필요한 경우

### 3. `~/app` 또는 `/home/ubuntu/app` (현재 사용 중)

**장점:**
- ✅ sudo 권한 불필요 (디렉토리 생성 시)
- ✅ 빠른 설정 및 테스트
- ✅ 개발/프로토타입에 적합

**단점:**
- ❌ 사용자 홈 디렉토리에 의존
- ❌ 사용자 삭제 시 위험
- ❌ 프로덕션 표준에 부적합
- ❌ 여러 사용자 환경에서 혼란 가능

**사용 시나리오:**
- 개발/테스트 환경
- 빠른 프로토타이핑
- 단일 사용자 환경

### 4. `/var/www/rag-app` (웹 애플리케이션 전통적)

**장점:**
- ✅ 웹 애플리케이션 전통적 위치
- ✅ Apache/Nginx와 함께 사용 시 익숙함

**단점:**
- ⚠️ `/var`는 일반적으로 로그/캐시용
- ⚠️ 코드보다는 데이터에 적합

## 🎯 권장 전략

### 프로덕션 환경: `/opt/rag-app` (권장)

```bash
# 디렉토리 구조
/opt/rag-app/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── models/
│   │   │   └── midm/
│   │   └── ...
│   └── requirements.txt
├── venv/              # Python 가상환경
├── .env               # 환경 변수 (권한: 600)
└── logs/              # 로그 파일 (선택사항)
```

### 개발/테스트 환경: `~/app` (현재)

```bash
# 디렉토리 구조
~/app/
├── backend/
│   ├── app/
│   └── requirements.txt
├── venv/
└── .env
```

## 🔧 `/opt/rag-app`으로 마이그레이션하기

### 1. GitHub Actions 워크플로우 업데이트

`.github/workflows/deploy-ec2.yml`에서 `PROJECT_DIR` 변경:

```yaml
env:
  PROJECT_DIR: /opt/rag-app
```

### 2. 초기 설정 스크립트 업데이트

`scripts/setup-ec2-direct.sh` 수정:

```bash
# 프로젝트 디렉토리 생성 (sudo 필요)
sudo mkdir -p /opt/rag-app
sudo mkdir -p /opt/rag-app/backend/app/models/midm

# 권한 설정 (ubuntu 사용자에게 소유권 부여)
sudo chown -R $USER:$USER /opt/rag-app
```

### 3. systemd 서비스 파일

systemd 서비스는 자동으로 생성되므로 변경 불필요 (워크플로우에서 처리)

### 4. 배포 후 확인

```bash
# 디렉토리 확인
ls -la /opt/rag-app

# 권한 확인
sudo ls -la /opt/rag-app

# 서비스 상태 확인
sudo systemctl status rag-fastapi
```

## 📊 비교 표

| 항목 | `/opt/rag-app` | `~/app` | `/srv/rag-app` | `/var/www/rag-app` |
|------|----------------|---------|----------------|-------------------|
| FHS 준수 | ✅ | ❌ | ✅ | ⚠️ |
| 프로덕션 적합 | ✅ | ❌ | ⚠️ | ⚠️ |
| sudo 필요 | ✅ | ❌ | ✅ | ✅ |
| 표준성 | ✅ | ❌ | ✅ | ⚠️ |
| 관리 용이성 | ✅ | ⚠️ | ✅ | ⚠️ |
| 빠른 설정 | ⚠️ | ✅ | ⚠️ | ⚠️ |

## 🚀 권장 사항

### CPU 기반 EC2 배포 시

1. **프로덕션 환경**: `/opt/rag-app` 사용
   - 표준화된 배포
   - 장기 운영에 적합
   - 시스템 관리 용이

2. **개발/테스트**: `~/app` 유지
   - 빠른 반복 개발
   - sudo 권한 불필요

### 마이그레이션 체크리스트

- [ ] GitHub Actions 워크플로우에서 `PROJECT_DIR` 변경
- [ ] 초기 설정 스크립트 업데이트
- [ ] EC2에서 기존 `~/app` 백업 (필요시)
- [ ] 새 위치로 배포 테스트
- [ ] 서비스 정상 작동 확인
- [ ] 기존 위치 정리 (선택사항)

## 💡 추가 고려사항

### 로그 파일 위치

로그는 별도 위치에 저장하는 것을 권장:

```bash
/var/log/rag-app/          # 애플리케이션 로그
/opt/rag-app/logs/        # 또는 프로젝트 내부
```

### 환경 변수 파일

`.env` 파일은 보안을 위해:
- 권한: `600` (소유자만 읽기/쓰기)
- 위치: `/opt/rag-app/.env`

### 백업 전략

```bash
# 전체 애플리케이션 백업
tar -czf rag-app-backup-$(date +%Y%m%d).tar.gz /opt/rag-app

# 모델 파일만 백업 (용량이 큰 경우)
tar -czf models-backup-$(date +%Y%m%d).tar.gz /opt/rag-app/backend/app/models/midm
```

