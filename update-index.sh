#!/bin/bash
set -e

# Функция для обновления индексного файла
update_index_file() {
  local file="$1"
  if [ -f "$file" ]; then
    # Создаем резервную копию
    cp "$file" "${file}.bak"
    
    # Добавляем скрипты перед </body>
    sed -i 's|</body>|<script src="/disable-sw.js"></script>\n<script src="/structured-data.js"></script>\n<script src="/sort-cities.js"></script>\n</body>|' "$file"
    
    echo "✅ Файл $file обновлен с добавлением скриптов"
    return 0
  fi
  return 1
}

# Пытаемся найти и обновить index.html в разных местах
if update_index_file "/root/escort-project/client/build/index.html"; then
  echo "✅ Найден и обновлен индексный файл в директории сборки"
elif update_index_file "/root/escort-project/client/public/index.html"; then
  echo "✅ Найден и обновлен индексный файл в директории public"
else
  echo "⚠️ Индексный файл не найден"
fi
