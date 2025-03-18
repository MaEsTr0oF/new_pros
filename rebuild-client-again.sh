#!/bin/bash
set -e

echo "🚀 Запускаем пересборку клиента"

# Переходим в директорию проекта
cd /root/escort-project

# Останавливаем контейнер клиента
echo "🛑 Останавливаем контейнер клиента"
docker-compose stop client
docker-compose rm -f client

# Очищаем кэш Docker для клиента
echo "🧹 Очищаем кэш Docker для клиента"
docker system prune -f --filter "label=com.docker.compose.project=escort-project" --filter "label=com.docker.compose.service=client"

# Пересобираем только клиент
echo "🏗️ Пересобираем клиент"
docker-compose build --no-cache client

# Запускаем клиент
echo "✅ Запускаем клиент"
docker-compose up -d client

# Даем время для запуска сервиса
echo "⏳ Ожидаем запуск клиента..."
sleep 10

echo "✅ Пересборка клиента завершена"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
