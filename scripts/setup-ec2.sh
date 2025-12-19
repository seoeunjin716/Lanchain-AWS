#!/bin/bash
# EC2 초기 설정 스크립트 (최초 1회만 실행)

set -e

echo "🔧 Setting up EC2 for deployment..."

# Docker 설치
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io docker-compose
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
    echo "✅ Docker installed. Please log out and log back in for group changes to take effect."
else
    echo "✅ Docker already installed"
fi

# 프로젝트 디렉토리 생성
mkdir -p ~/app
mkdir -p ~/app/backend/app/models/midm

# 권한 설정
sudo chown -R $USER:$USER ~/app

# .env 파일 템플릿 생성 (사용자가 직접 채워야 함)
if [ ! -f ~/app/.env ]; then
    cat > ~/app/.env << EOF
# Database
POSTGRES_CONNECTION_STRING=your_postgres_connection_string_here

# API Keys
OPENAI_API_KEY=your_openai_api_key_here
EOF
    echo "📝 Created .env template at ~/app/.env"
    echo "⚠️  Please edit ~/app/.env and fill in your credentials"
fi

echo "✅ EC2 setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Edit ~/app/.env with your credentials"
echo "2. Upload model files to ~/app/backend/app/models/midm/ (if not using S3)"
echo "3. Set up GitHub Actions secrets (EC2_HOST, EC2_USER, EC2_SSH_KEY, etc.)"
echo "4. Push to main branch to trigger deployment"

