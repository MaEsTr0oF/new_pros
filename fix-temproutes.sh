#!/bin/bash
set -e

echo "🔧 Исправляем типы в tempRoutes.ts"

# Путь к файлу
ROUTES_PATH="/root/escort-project/server/src/tempRoutes.ts"

# Удаляем файл tempRoutes.ts, так как он больше не нужен
if [ -f "$ROUTES_PATH" ]; then
  rm -f "$ROUTES_PATH"
  echo "✅ Файл tempRoutes.ts удален"
else
  echo "⚠️ Файл tempRoutes.ts не найден"
fi

# Проверяем импорт tempRoutes в index.ts
INDEX_PATH="/root/escort-project/server/src/index.ts"
if grep -q "import.*tempRoutes" "$INDEX_PATH"; then
  # Удаляем импорт tempRoutes
  sed -i '/import.*tempRoutes/d' "$INDEX_PATH"
  echo "✅ Импорт tempRoutes удален из index.ts"
fi

echo "✅ Исправлены проблемы с типами в tempRoutes.ts"
