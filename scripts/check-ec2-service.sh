#!/bin/bash
# EC2 서비스 상태 확인 스크립트

echo "🔍 EC2 서비스 상태 확인 중..."
echo "=================================="

# 1. 서비스 상태 확인
echo ""
echo "1️⃣ systemd 서비스 상태:"
sudo systemctl status rag-fastapi --no-pager -l

# 2. 포트 리스닝 확인
echo ""
echo "2️⃣ 포트 8000 리스닝 확인:"
if sudo netstat -tlnp | grep 8000; then
    echo "✅ 포트 8000이 리스닝 중입니다"
else
    echo "❌ 포트 8000이 리스닝되지 않습니다"
fi

# 3. 프로세스 확인
echo ""
echo "3️⃣ uvicorn 프로세스 확인:"
ps aux | grep uvicorn | grep -v grep || echo "❌ uvicorn 프로세스가 실행 중이 아닙니다"

# 4. 방화벽 상태
echo ""
echo "4️⃣ UFW 방화벽 상태:"
sudo ufw status

# 5. 로컬 연결 테스트
echo ""
echo "5️⃣ 로컬 연결 테스트:"
if curl -f http://localhost:8000/api/v1/health 2>/dev/null; then
    echo "✅ 로컬 연결 성공"
else
    echo "❌ 로컬 연결 실패"
fi

# 6. 최근 서비스 로그
echo ""
echo "6️⃣ 최근 서비스 로그 (마지막 30줄):"
sudo journalctl -u rag-fastapi -n 30 --no-pager

# 7. 환경 변수 확인
echo ""
echo "7️⃣ 환경 변수 파일 확인:"
if [ -f /home/ubuntu/rag-app/.env ]; then
    echo "✅ .env 파일 존재"
    echo "POSTGRES_CONNECTION_STRING 설정 여부:"
    grep -q "POSTGRES_CONNECTION_STRING" /home/ubuntu/rag-app/.env && echo "✅ 설정됨" || echo "❌ 설정되지 않음"
else
    echo "❌ .env 파일이 없습니다"
fi

# 8. 디렉토리 및 파일 확인
echo ""
echo "8️⃣ 배포 디렉토리 확인:"
if [ -d /home/ubuntu/rag-app ]; then
    echo "✅ 디렉토리 존재"
    echo "main.py 존재 여부:"
    [ -f /home/ubuntu/rag-app/main.py ] && echo "✅ 존재" || echo "❌ 없음"
    echo "requirements.txt 존재 여부:"
    [ -f /home/ubuntu/rag-app/requirements.txt ] && echo "✅ 존재" || echo "❌ 없음"
else
    echo "❌ 배포 디렉토리가 없습니다"
fi

echo ""
echo "=================================="
echo "✅ 확인 완료"

