#!/bin/bash
# EC2에서 직접 실행할 수 있는 배포 스크립트 (Docker 없이 systemd 사용)

set -e

echo "🚀 Starting FastAPI deployment..."

PROJECT_DIR=/opt/rag-app
SERVICE_NAME=rag-fastapi

# 디렉토리 확인
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Project directory not found: $PROJECT_DIR"
    echo "   Please run setup-ec2-direct.sh first"
    exit 1
fi

cd $PROJECT_DIR

# 환경 변수 확인
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    exit 1
fi

# Python 가상환경 확인 및 생성
if [ ! -d venv ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# 가상환경 활성화 및 의존성 설치
echo "📦 Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r backend/requirements.txt

# systemd 서비스 파일 생성/업데이트
echo "📝 Creating systemd service..."
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOF
[Unit]
Description=RAG FastAPI Application
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment="PATH=$PROJECT_DIR/venv/bin"
EnvironmentFile=$PROJECT_DIR/.env
ExecStart=$PROJECT_DIR/venv/bin/uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --workers 2
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# systemd 재로드 및 서비스 재시작
echo "🔄 Reloading systemd and restarting service..."
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}
sudo systemctl restart ${SERVICE_NAME}

# 헬스 체크
echo "🏥 Waiting for service to be ready..."
sleep 10

for i in {1..30}; do
    if curl -f http://localhost:8000/api/v1/health > /dev/null 2>&1; then
        echo "✅ Health check passed!"
        echo "🌐 Backend API: http://localhost:8000"
        echo "📚 API Docs: http://localhost:8000/docs"
        echo ""
        echo "📊 Service status:"
        sudo systemctl status ${SERVICE_NAME} --no-pager
        exit 0
    fi
    echo "Attempt $i/30: Service not ready yet, waiting..."
    sleep 2
done

echo "❌ Health check failed!"
echo "📋 Service logs:"
sudo journalctl -u ${SERVICE_NAME} -n 50 --no-pager
exit 1

