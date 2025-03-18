#!/bin/bash
set -e

echo "🔍 Проверяем все вызовы API в проекте"

# Находим все файлы TypeScript/JavaScript в директории client/src
find /root/escort-project/client/src -type f -name "*.ts" -o -name "*.tsx" | while read -r file; do
  # Ищем вызовы api.get, api.post, api.put, api.delete и т.д.
  if grep -q "api\.\(get\|post\|put\|delete\|patch\)" "$file"; then
    echo "⚠️ Найдены прямые вызовы API в файле: $file"
    
    # Создаем резервную копию
    cp "$file" "${file}.bak_api"
    
    # Исправляем прямые вызовы API
    sed -i 's/api\.get(.api\/admin\/profiles.)/api.profiles.getAll()/g' "$file"
    sed -i 's/api\.get(.api\/admin\/profiles\/\([^)]*\).)/api.profiles.getById(\1)/g' "$file"
    sed -i 's/api\.post(.api\/admin\/profiles.)/api.profiles.create()/g' "$file"
    sed -i 's/api\.put(.api\/admin\/profiles\/\([^)]*\).)/api.profiles.update(\1)/g' "$file"
    sed -i 's/api\.delete(.api\/admin\/profiles\/\([^)]*\).)/api.profiles.delete(\1)/g' "$file"
    
    # Аналогично для городов
    sed -i 's/api\.get(.api\/cities.)/api.cities.getAll()/g' "$file"
    sed -i 's/api\.post(.api\/admin\/cities.)/api.cities.create()/g' "$file"
    sed -i 's/api\.put(.api\/admin\/cities\/\([^)]*\).)/api.cities.update(\1)/g' "$file"
    sed -i 's/api\.delete(.api\/admin\/cities\/\([^)]*\).)/api.cities.delete(\1)/g' "$file"
    
    # И для авторизации
    sed -i 's/api\.post(.api\/auth\/login.)/api.auth.login()/g' "$file"
    
    echo "✅ Исправлены вызовы API в файле: $file"
  fi
done

echo "✅ Проверка вызовов API в проекте завершена"
