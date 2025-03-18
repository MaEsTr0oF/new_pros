#!/bin/bash
# Проверяем, есть ли уже маршруты для перемещения профилей
if grep -q "move-up" /root/escort-project/server/src/index.ts; then
  echo "Маршруты для перемещения профилей уже существуют"
else
  # Находим место, где определены защищенные маршруты администратора
  LINE_NUM=$(grep -n "app.put('/api/admin/profiles/:id'" /root/escort-project/server/src/index.ts | cut -d: -f1)
  if [ -z "$LINE_NUM" ]; then
    echo "Не удалось найти место для добавления маршрутов"
    exit 1
  fi
  
  # Добавляем новые маршруты после найденной строки
  sed -i "${LINE_NUM}a app.patch('/api/admin/profiles/:id/move-up', profileController.moveProfileUp);\napp.patch('/api/admin/profiles/:id/move-down', profileController.moveProfileDown);" /root/escort-project/server/src/index.ts
  
  echo "Маршруты для перемещения профилей добавлены"
fi

# Проверяем, есть ли уже импорт middleware
if grep -q "apiMiddleware" /root/escort-project/server/src/index.ts; then
  echo "Импорт API middleware уже существует"
else
  # Добавляем импорт middleware в начало файла
  sed -i "1s/^/import apiMiddleware from '.\/middleware\/api-middleware';\n/" /root/escort-project/server/src/index.ts
  
  # Находим место, где определены middleware
  LINE_NUM=$(grep -n "app.use(express.json" /root/escort-project/server/src/index.ts | head -1 | cut -d: -f1)
  if [ -z "$LINE_NUM" ]; then
    echo "Не удалось найти место для добавления middleware"
    exit 1
  fi
  
  # Добавляем использование middleware после найденной строки
  sed -i "${LINE_NUM}a // Применяем API middleware\napp.use('/api', apiMiddleware);" /root/escort-project/server/src/index.ts
  
  echo "Импорт и использование API middleware добавлены"
fi
