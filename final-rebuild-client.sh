#!/bin/bash
set -e

echo "🚀 Запускаем финальную пересборку клиента"

# Переходим в директорию проекта
cd /root/escort-project

# Останавливаем контейнер клиента
echo "🛑 Останавливаем контейнер клиента"
docker-compose stop client
docker-compose rm -f client

# Очищаем кэш Docker для клиента
echo "🧹 Очищаем кэш Docker"
docker builder prune -f

# Пересобираем только клиент
echo "🏗️ Пересобираем клиент"
docker-compose build --no-cache client

# Запускаем клиент
echo "✅ Запускаем клиент"
docker-compose up -d client

# Даем время для запуска сервиса
echo "⏳ Ожидаем запуск клиента..."
sleep 10

# Проверяем статус контейнера
echo "🔍 Проверяем статус контейнера клиента"
docker ps -a | grep escort-client

echo "✅ Пересборка клиента завершена"
echo "�� Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
