#!/bin/bash
# EC2에서 수동으로 배포하는 스크립트

set -e

echo "🚀 FastAPI 수동 배포 시작..."
echo "=================================="

PROJECT_DIR=/home/ubuntu/rag-app
SERVICE_NAME=rag-fastapi

# 1. 디렉토리 확인
echo ""
echo "1️⃣ 배포 디렉토리 확인..."
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ 배포 디렉토리가 없습니다. 생성합니다..."
    mkdir -p $PROJECT_DIR
    mkdir -p $PROJECT_DIR/models/midm
    echo "✅ 디렉토리 생성 완료"
else
    echo "✅ 배포 디렉토리 존재: $PROJECT_DIR"
fi

cd $PROJECT_DIR

# 2. 파일 확인
echo ""
echo "2️⃣ 필수 파일 확인..."
if [ ! -f "main.py" ]; then
    echo "❌ main.py가 없습니다!"
    echo "GitHub Actions 배포가 실행되지 않았거나 실패한 것 같습니다."
    echo ""
    echo "다음 중 하나를 선택하세요:"
    echo "1. GitHub Actions에서 배포를 다시 실행"
    echo "2. 수동으로 코드를 업로드"
    exit 1
fi
echo "✅ main.py 존재"

# 3. 환경 변수 파일 확인
echo ""
echo "3️⃣ 환경 변수 파일 확인..."
if [ ! -f ".env" ]; then
    echo "⚠️  .env 파일이 없습니다. 생성합니다..."
    cat > .env << EOF
POSTGRES_CONNECTION_STRING=your_postgres_connection_string_here
OPENAI_API_KEY=your_openai_api_key_here
EOF
    echo "✅ .env 파일 생성됨"
    echo "⚠️  .env 파일을 수정하여 실제 값으로 변경하세요!"
    echo "   nano $PROJECT_DIR/.env"
else
    echo "✅ .env 파일 존재"
fi

# 4. Python 가상환경 확인 및 생성
echo ""
echo "4️⃣ Python 가상환경 확인..."
if [ ! -d "venv" ]; then
    echo "📦 Python 가상환경 생성 중..."
    python3 -m venv venv
    echo "✅ 가상환경 생성 완료"
else
    echo "✅ 가상환경 존재"
fi

# 5. 의존성 설치
echo ""
echo "5️⃣ 의존성 설치..."
source venv/bin/activate
pip install --upgrade pip

if [ -f "requirements.txt" ]; then
    echo "📦 requirements.txt에서 패키지 설치 중..."
    pip install -r requirements.txt
    echo "✅ 의존성 설치 완료"
else
    echo "⚠️  requirements.txt가 없습니다!"
    echo "기본 패키지만 설치합니다..."
    pip install fastapi uvicorn[standard]
fi

# 6. systemd 서비스 파일 생성
echo ""
echo "6️⃣ systemd 서비스 파일 생성..."
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOFSERVICE
[Unit]
Description=RAG FastAPI Application
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment="PATH=$PROJECT_DIR/venv/bin"
EnvironmentFile=$PROJECT_DIR/.env
ExecStart=$PROJECT_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOFSERVICE

echo "✅ 서비스 파일 생성 완료"

# 7. systemd 재로드 및 서비스 시작
echo ""
echo "7️⃣ systemd 재로드 및 서비스 시작..."
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}
sudo systemctl restart ${SERVICE_NAME}

# 8. 서비스 상태 확인
echo ""
echo "8️⃣ 서비스 상태 확인..."
sleep 3
sudo systemctl status ${SERVICE_NAME} --no-pager -l

# 9. 헬스 체크
echo ""
echo "9️⃣ 헬스 체크..."
sleep 5
for i in {1..10}; do
    if curl -f http://localhost:8000/api/v1/health > /dev/null 2>&1; then
        echo "✅ 헬스 체크 성공!"
        echo ""
        echo "🌐 서비스가 정상적으로 실행 중입니다!"
        echo "   API: http://$(curl -s ifconfig.me):8000"
        echo "   Docs: http://$(curl -s ifconfig.me):8000/docs"
        exit 0
    fi
    echo "Attempt $i/10: 서비스 시작 대기 중..."
    sleep 2
done

echo "❌ 헬스 체크 실패!"
echo "📋 서비스 로그:"
sudo journalctl -u ${SERVICE_NAME} -n 50 --no-pager
exit 1

