#!/bin/bash
# Полная замена всех упоминаний localhost:5001 во всех файлах исходного кода
find ./client/src -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" \) -exec sed -i 's|localhost:5001|eskortvsegorodarfreal.site|g' {} \;

# Перезапускаем контейнеры после изменений
docker-compose down
docker-compose build --no-cache client
docker-compose up -d
