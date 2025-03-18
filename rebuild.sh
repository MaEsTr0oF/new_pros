#!/bin/bash
set -e

echo "🚀 Начинаем полную пересборку проекта"

# Переходим в директорию проекта
cd /root/escort-project

# Запускаем скрипт обновления сервера
./update-server.sh

# Останавливаем все контейнеры
echo "🛑 Останавливаем все контейнеры"
docker-compose down
docker rm -f escort-proxy escort-api-server || true

# Очищаем Docker-кэш
echo "🧹 Очищаем Docker-кэш"
docker system prune -af --volumes

# Пересобираем проект без использования кэша
echo "🏗️ Пересобираем проект"
docker-compose build --no-cache

# Запускаем проект
echo "✅ Запускаем проект"
docker-compose up -d

# Ждем, пока база данных запустится
echo "⏳ Ждем запуска базы данных"
sleep 15

# Выполняем SQL для сортировки городов
echo "🔄 Сортируем города в базе данных"
docker exec escort-postgres psql -U postgres -d escort_db -f /docker-entrypoint-initdb.d/sort-cities-db.sql || true

# Копируем SQL-скрипт в контейнер
docker cp /root/escort-project/sort-cities-db.sql escort-postgres:/docker-entrypoint-initdb.d/

# Выполняем SQL для сортировки городов
docker exec escort-postgres psql -U postgres -d escort_db -f /docker-entrypoint-initdb.d/sort-cities-db.sql

# Запускаем скрипт обновления HTML после сборки
./update-html.sh

# Финальные настройки
echo "🔄 Выполняем финальные настройки"
docker exec escort-client mkdir -p /usr/share/nginx/html/js
docker cp /root/escort-project/client/public/structured-data.js escort-client:/usr/share/nginx/html/js/
docker cp /root/escort-project/client/public/disable-sw.js escort-client:/usr/share/nginx/html/js/
docker cp /root/escort-project/client/public/sort-cities.js escort-client:/usr/share/nginx/html/js/

# Обновляем index.html в контейнере
docker exec escort-client sh -c "sed -i '/<head>/a <script src=\"/js/sort-cities.js\"></script>' /usr/share/nginx/html/index.html"
docker exec escort-client sh -c "sed -i '/<head>/a <script src=\"/js/disable-sw.js\"></script>' /usr/share/nginx/html/index.html"
docker exec escort-client sh -c "sed -i '/<head>/a <script src=\"/js/structured-data.js\"></script>' /usr/share/nginx/html/index.html"

# Перезагружаем Nginx
docker exec escort-client nginx -s reload

echo "✅ Пересборка проекта завершена"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
