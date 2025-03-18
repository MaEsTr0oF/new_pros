#!/bin/bash
set -e

echo "🚀 Запускаем финальную пересборку клиента"

# Переходим в директорию проекта
cd /root/escort-project

# Останавливаем все контейнеры
echo "🛑 Останавливаем все контейнеры"
docker-compose down

# Очищаем кэш Docker
echo "🧹 Очищаем кэш Docker"
docker system prune -f

# Пересобираем проект
echo "🏗️ Пересобираем проект"
docker-compose build --no-cache

# Запускаем проект
echo "✅ Запускаем проект"
docker-compose up -d

# Даем время для запуска сервисов
echo "⏳ Ожидаем запуск сервисов..."
sleep 20

echo "✅ Пересборка завершена"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
