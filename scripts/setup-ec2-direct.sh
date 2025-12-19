#!/bin/bash
# EC2 초기 설정 스크립트 (Docker 없이 직접 실행 방식)

set -e

echo "🔧 Setting up EC2 for FastAPI deployment..."

# 시스템 업데이트
echo "📦 Updating system packages..."
sudo apt update
sudo apt upgrade -y

# 필수 패키지 설치
echo "📦 Installing essential packages..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    git \
    postgresql-client \
    build-essential \
    libpq-dev

# 프로젝트 디렉토리 생성 (프로덕션 표준 위치: /opt/rag-app)
PROJECT_DIR=/opt/rag-app
sudo mkdir -p $PROJECT_DIR
sudo mkdir -p $PROJECT_DIR/backend/app/models/midm

# 권한 설정
sudo chown -R $USER:$USER $PROJECT_DIR

# .env 파일 템플릿 생성
if [ ! -f $PROJECT_DIR/.env ]; then
    cat > $PROJECT_DIR/.env << EOF
# Database
POSTGRES_CONNECTION_STRING=your_postgres_connection_string_here

# API Keys
OPENAI_API_KEY=your_openai_api_key_here
EOF
    echo "📝 Created .env template at $PROJECT_DIR/.env"
    echo "⚠️  Please edit $PROJECT_DIR/.env and fill in your credentials"
    # .env 파일 권한 설정 (보안)
    chmod 600 $PROJECT_DIR/.env
fi

# 방화벽 설정 (UFW)
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 8000/tcp # FastAPI
sudo ufw --force enable

echo "✅ EC2 setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Edit $PROJECT_DIR/.env with your credentials"
echo "2. Upload model files to $PROJECT_DIR/backend/app/models/midm/ (if needed)"
echo "3. Set up GitHub Actions secrets:"
echo "   - EC2_HOST: ec2-54-180-101-84.ap-northeast-2.compute.amazonaws.com"
echo "   - EC2_USER: ubuntu"
echo "   - EC2_SSH_KEY: (your private key content)"
echo "4. Push to main branch to trigger deployment"

