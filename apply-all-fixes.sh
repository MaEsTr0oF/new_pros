#!/bin/bash
set -e

echo "🚀 Применяем все исправления"

# Делаем все скрипты исполняемыми
chmod +x /root/escort-project/fix-auth.sh
chmod +x /root/escort-project/fix-image-upload.sh
chmod +x /root/escort-project/fix-serviceworker.sh
chmod +x /root/escort-project/fix-profiles-loading.sh

# Запускаем все скрипты
echo "🔧 Исправляем авторизацию..."
./fix-auth.sh

echo "🔧 Исправляем загрузку изображений..."
./fix-image-upload.sh

echo "🔧 Исправляем ServiceWorker..."
./fix-serviceworker.sh

echo "🔧 Исправляем загрузку профилей..."
./fix-profiles-loading.sh

echo "🏗️ Пересобираем клиент"
cd /root/escort-project

# Останавливаем контейнер клиента
docker-compose stop client
docker-compose rm -f client

# Очищаем кэш Docker
docker builder prune -f

# Пересобираем только клиент
docker-compose build --no-cache client

# Запускаем клиент
docker-compose up -d client

echo "⏳ Ожидаем запуск клиента..."
sleep 10

echo "✅ Все исправления применены и клиент перезапущен"
echo "�� Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
