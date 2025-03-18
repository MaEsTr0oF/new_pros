#!/bin/bash
set -e

echo "🔧 Исправляем ошибки типизации в файлах"

# Находим файл с ошибкой сортировки
find /root/escort-project/client/src -type f -name "*.tsx" -o -name "*.ts" | xargs grep -l "sort((a, b) => (a.order || 0) - (b.order || 0))" | while read -r file; do
  echo "🔍 Найдена сортировка без типизации в файле: $file"
  
  # Создаем резервную копию
  cp "$file" "${file}.bak_type"
  
  # Исправляем ошибку типизации, добавляя явные типы параметров
  sed -i 's/sort((a, b) => (a.order || 0) - (b.order || 0))/sort((a: Profile, b: Profile) => (a.order || 0) - (b.order || 0))/g' "$file"
  
  echo "✅ Исправлена типизация в файле: $file"
done

echo "✅ Исправления типизации завершены"
