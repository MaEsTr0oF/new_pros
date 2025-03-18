#!/bin/bash
set -e

echo "🔧 Проверяем все импорты API в проекте"

# Находим все файлы TypeScript/JavaScript в директории client/src
find /root/escort-project/client/src -type f -name "*.ts" -o -name "*.tsx" | while read -r file; do
  if grep -q "import.*from '../../api';" "$file"; then
    echo "🔎 Найден импорт API в файле: $file"
    
    # Исправляем формат импорта, если он отличается от ожидаемого
    if ! grep -q "import { api } from '../../api';" "$file"; then
      # Делаем резервную копию
      cp "$file" "${file}.bak"
      
      # Исправляем импорт
      sed -i "s/import.*from '..\/..\/api';/import { api } from '..\/..\/api';/g" "$file"
      echo "✅ Исправлен импорт API в файле: $file"
    fi
  fi
done

echo "✅ Проверка импортов API завершена"
