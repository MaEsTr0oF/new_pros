#!/bin/bash
set -e

echo "🔧 Исправляем маршруты в index.ts"

# Путь к файлу
INDEX_PATH="/root/escort-project/server/src/index.ts"

# Создаем резервную копию
cp $INDEX_PATH ${INDEX_PATH}.bak

# Добавляем импорт middleware
sed -i "/import \* as settingsController/a import apiMiddleware from './middlewares/api-middleware';" $INDEX_PATH

# Добавляем использование middleware
sed -i "/app.get('\/api\/health'/a app.use('/api', apiMiddleware);" $INDEX_PATH

# Добавляем маршруты для перемещения профилей
sed -i "/app.patch('\/api\/admin\/profiles\/:id\/verify', profileController.verifyProfile;/a app.patch('/api/admin/profiles/:id/moveUp', profileController.moveProfileUp);\napp.patch('/api/admin/profiles/:id/moveDown', profileController.moveProfileDown);" $INDEX_PATH

echo "✅ Маршруты в index.ts исправлены"
