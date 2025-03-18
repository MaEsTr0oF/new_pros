#!/bin/bash
# Скрипт для обновления index.ts

# Путь к index.ts
INDEX_PATH="/root/escort-project/server/src/index.ts"

# Добавляем импорт API-мидлвара
sed -i "/import \* as settingsController/a import apiMiddleware from './middlewares/api-middleware';" $INDEX_PATH

# Добавляем использование API-мидлвара перед маршрутами
sed -i "/app.get('\/api\/health'/a app.use('/api', apiMiddleware);" $INDEX_PATH

echo "Файл index.ts обновлен"
