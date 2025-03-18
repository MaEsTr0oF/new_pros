#!/bin/bash
set -e

echo "🔍 Создаем временный контейнер для проверки TypeScript без сборки"

# Переходим в директорию проекта
cd /root/escort-project

# Создаем временный Dockerfile для проверки TypeScript
cat > typescript-check.Dockerfile << 'EOFINNER'
FROM node:18-alpine
WORKDIR /app
COPY client/package*.json ./
RUN npm install
COPY client/ ./
CMD ["npx", "tsc", "--noEmit"]
EOFINNER

# Создаем временный контейнер для проверки TypeScript
docker build -t typescript-check -f typescript-check.Dockerfile .

echo "🔍 Запускаем проверку TypeScript"
docker run --rm typescript-check

echo "✅ Проверка TypeScript завершена"
