#!/bin/bash
# EC2에서 직접 실행할 수 있는 배포 스크립트

set -e

echo "🚀 Starting deployment..."

cd ~/app

# 환경 변수 확인
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    exit 1
fi

# Docker Compose로 배포
echo "📦 Building and starting containers..."
docker-compose -f docker-compose.prod.yaml down || true
docker-compose -f docker-compose.prod.yaml up -d --build

# 헬스 체크
echo "🏥 Waiting for service to be ready..."
sleep 15

for i in {1..30}; do
    if curl -f http://localhost:8000/api/v1/health > /dev/null 2>&1; then
        echo "✅ Health check passed!"
        echo "🌐 Backend API: http://localhost:8000"
        echo "📚 API Docs: http://localhost:8000/docs"
        exit 0
    fi
    echo "Attempt $i/30: Service not ready yet, waiting..."
    sleep 2
done

echo "❌ Health check failed!"
docker-compose -f docker-compose.prod.yaml logs
exit 1

