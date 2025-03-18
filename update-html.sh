#!/bin/bash
# Скрипт для обновления index.html

# Путь к index.html
INDEX_HTML="/root/escort-project/client/build/index.html"

# Создаем папку для скриптов
mkdir -p /root/escort-project/client/build/js

# Копируем скрипты
cp /root/escort-project/client/public/structured-data.js /root/escort-project/client/build/js/
cp /root/escort-project/client/public/disable-sw.js /root/escort-project/client/build/js/
cp /root/escort-project/client/public/sort-cities.js /root/escort-project/client/build/js/

# Добавляем скрипты в head
sed -i '/<head>/a <script src="/js/structured-data.js"></script>' $INDEX_HTML
sed -i '/<head>/a <script src="/js/disable-sw.js"></script>' $INDEX_HTML
sed -i '/<head>/a <script src="/js/sort-cities.js"></script>' $INDEX_HTML

echo "Файл index.html обновлен"
