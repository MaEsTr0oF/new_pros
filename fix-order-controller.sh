#!/bin/bash
set -e

echo "🔄 Исправляем orderBy в profileController.ts"

# Путь к файлу
CONTROLLER_PATH="/root/escort-project/server/src/controllers/profileController.ts"

# Создаем резервную копию
cp $CONTROLLER_PATH ${CONTROLLER_PATH}.bak3

# Ищем строку с orderBy в функции getProfiles
LINE_NUM=$(grep -n "orderBy:" $CONTROLLER_PATH | head -1 | cut -d: -f1)

if [ -n "$LINE_NUM" ]; then
  # Заменяем orderBy на правильную версию
  sed -i "${LINE_NUM},+4c\      orderBy: {\n        createdAt: 'desc'\n      }" $CONTROLLER_PATH
  echo "✅ Исправлена сортировка в функции getProfiles"
else
  echo "⚠️ Не найдена строка orderBy в файле"
fi

echo "✅ profileController.ts исправлен"
