#!/bin/bash
# Создаем полный, правильно закрытый скрипт
file="/root/escort-project/server/src/controllers/profileController.ts"

# Добавляем импорт функций moveProfileUp и moveProfileDown
if ! grep -q "import { moveProfileUp, moveProfileDown } from './profileOrder';" "$file"; then
  # Добавляем импорт в начало файла
  sed -i '1i import { moveProfileUp, moveProfileDown } from "./profileOrder";' "$file"
fi

# Добавляем экспорт в конец файла
if ! grep -q "export { moveProfileUp, moveProfileDown };" "$file"; then
  echo 'export { moveProfileUp, moveProfileDown };' >> "$file"
fi

# Изменяем сортировку в getProfiles
if grep -q "orderBy:" "$file"; then
  sed -i '/orderBy:/,/}/c\      orderBy: {\n        order: "asc"\n      }' "$file"
fi
