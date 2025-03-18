#!/bin/bash

echo "�� Исправление всех импортов API в проекте..."

# Находим все файлы с импортом apiClient из api-wrapper
FILES_WITH_API_CLIENT=$(grep -l "import.*apiClient.*from.*api-wrapper" --include="*.tsx" --include="*.ts" ./client/src)

for file in $FILES_WITH_API_CLIENT; do
  echo "📄 Исправление импорта в файле $file"
  # Заменяем импорт apiClient на импорт api из api/index.ts
  sed -i 's/import { apiClient } from "..\/..\/api-wrapper";/import api from "..\/..\/api\/index";/g' $file
  sed -i 's/import { apiClient } from "..\/api-wrapper";/import api from "..\/api\/index";/g' $file
  # Заменяем использование apiClient на api
  sed -i 's/apiClient\./api\./g' $file
done

echo "✅ Импорты API исправлены!"
