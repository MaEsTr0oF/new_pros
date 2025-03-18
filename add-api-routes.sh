#!/bin/bash
set -e

echo "🔧 Добавляем маршруты для перемещения профилей в index.ts"

# Путь к файлу
INDEX_PATH="/root/escort-project/server/src/index.ts"

# Создаем резервную копию
cp $INDEX_PATH ${INDEX_PATH}.bak

# Проверяем наличие маршрутов и добавляем, если их нет
if ! grep -q "app.patch('/api/admin/profiles/:id/moveUp'" $INDEX_PATH; then
  # Добавляем маршруты перед строкой с app.get('/api/admin/settings'
  sed -i '/app.get(.api.admin.settings/i app.patch('"'\/api\/admin\/profiles\/:id\/moveUp'"', profileController.moveProfileUp);' $INDEX_PATH
  sed -i '/app.get(.api.admin.settings/i app.patch('"'\/api\/admin\/profiles\/:id\/moveDown'"', profileController.moveProfileDown);' $INDEX_PATH
  echo "✅ Маршруты для перемещения профилей добавлены"
else
  echo "✅ Маршруты для перемещения профилей уже существуют"
fi
