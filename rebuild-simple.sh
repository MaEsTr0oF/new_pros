#!/bin/bash
set -e

echo "🚀 Запускаем пересборку проекта с исправлениями"

# Переходим в директорию проекта
cd /root/escort-project

# Останавливаем все контейнеры
echo "🛑 Останавливаем все контейнеры"
docker-compose down
docker rm -f escort-proxy escort-api-server 2>/dev/null || true

# Пересобираем проект
echo "🏗️ Пересобираем проект"
docker-compose build --no-cache server

# Запускаем проект
echo "✅ Запускаем проект"
docker-compose up -d

# Даем время для запуска сервисов
echo "⏳ Ожидаем запуск сервисов..."
sleep 10

# Копируем скрипт исправления структурированных данных
echo "📄 Копируем скрипт исправления структурированных данных"
docker cp /root/escort-project/client/build/js/fix-schema.js escort-client:/usr/share/nginx/html/js/fix-schema.js

# Обновляем index.html
echo "📄 Обновляем index.html"
docker exec escort-client sh -c "grep -q 'fix-schema.js' /usr/share/nginx/html/index.html || sed -i '/<head>/a <script src=\"/js/fix-schema.js\"></script>' /usr/share/nginx/html/index.html"

# Перезагружаем Nginx
echo "🔄 Перезагружаем Nginx"
docker exec escort-client nginx -s reload

echo "✅ Пересборка проекта завершена"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
