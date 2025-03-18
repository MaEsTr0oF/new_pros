#!/bin/bash
set -e

echo "🔍 Проверяю состояние сборки React-приложения..."

# 1. Проверяем структуру сборки внутри контейнера
echo "📁 Структура файлов в директории Nginx:"
docker exec escort-client ls -la /usr/share/nginx/html

# 2. Проверяем содержимое index.html
echo "📄 Проверяем содержимое index.html:"
docker exec escort-client cat /usr/share/nginx/html/index.html | head -30

# 3. Проверяем наличие и размер JS и CSS файлов
echo "🔍 Проверяем JS и CSS файлы:"
docker exec escort-client find /usr/share/nginx/html -name "*.js" -o -name "*.css" | xargs ls -lh || true

# 4. Проверяем логи доступа к серверу
echo "📊 Проверяем логи доступа к серверу:"
docker exec escort-client tail -n 20 /var/log/nginx/access.log || true

# 5. Проверяем логи ошибок сервера
echo "⚠️ Проверяем логи ошибок сервера:"
docker exec escort-client tail -n 20 /var/log/nginx/error.log || true

# 6. Попробуем выполнить сборку локально с выводом всех ошибок
echo "🔄 Пробуем выполнить сборку локально с выводом ошибок:"
cd /root/escort-project/client
export CI=false
export SKIP_PREFLIGHT_CHECK=true
export DISABLE_ESLINT_PLUGIN=true
npm run build 2>&1 | tee /tmp/build-output.log || true

echo "📑 Результаты сборки сохранены в /tmp/build-output.log"

# 7. Проверка зависимостей и конфигурации
echo "📦 Проверка конфигурации проекта:"
echo "package.json:"
cat package.json | grep -A 20 "dependencies" | head -20

echo ""
echo "✅ Проверка сборки React-приложения завершена"
echo "🔎 Для более детальной диагностики можно:"
echo "  1. Проверить содержимое /tmp/build-output.log"
echo "  2. Просмотреть консоль браузера при обращении к сайту"
echo "  3. Временно использовать режим разработки (npm start) для получения более подробных ошибок"
