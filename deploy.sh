#!/bin/bash

echo "🚀 Запуск проекта на сервере"

# Проверка наличия docker-compose
if ! [ -x "$(command -v docker-compose)" ]; then
  echo "❌ Ошибка: docker-compose не установлен"
  echo "⚠️ Сначала выполните скрипт setup-server.sh"
  exit 1
fi

# Создание переменных окружения
echo "📝 Создание файла .env..."
cat > .env << EOF
JWT_SECRET=your_jwt_secret_key_qwertyuiopasdfghjklzxcvbnm
CLIENT_URL=https://eskortvsegorodarfreal.site
API_URL=https://eskortvsegorodarfreal.site/api
EOF

# Запуск контейнеров
echo "🐳 Запуск контейнеров Docker..."
docker-compose up -d

echo "⏳ Ожидание запуска контейнеров..."
sleep 10

# Проверка статуса контейнеров
echo "🔍 Проверка статуса контейнеров..."
docker-compose ps

echo "✅ Проект успешно запущен!"
echo "📝 Админ-панель доступна по адресу: https://eskortvsegorodarfreal.site/admin"
echo "🔑 API доступно по адресу: https://eskortvsegorodarfreal.site/api"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
echo ""
echo "🔒 Для настройки SSL-сертификата выполните скрипт setup-ssl.sh" 