#!/bin/bash
set -e

echo "🔧 Исправляем проблемы с ServiceWorker"

# Путь к основному индексному файлу React
INDEX_FILE="/root/escort-project/client/src/index.tsx"
SW_FILE="/root/escort-project/client/public/sw.js"

# Создаем скрипт для отключения ServiceWorker
cat > "/root/escort-project/client/public/sw-disable.js" << 'EOFINNER'
// Скрипт для отключения проблемного ServiceWorker
if ('serviceWorker' in navigator) {
  console.log('Отключаем ServiceWorker...');
  navigator.serviceWorker.getRegistrations().then(function(registrations) {
    for(let registration of registrations) {
      console.log('Отключение ServiceWorker:', registration.scope);
      registration.unregister();
    }
    console.log('Все ServiceWorker отключены');
  }).catch(err => {
    console.error('Ошибка при отключении ServiceWorker:', err);
  });
}
EOFINNER

# Добавляем тег script в index.html для загрузки скрипта отключения
if [ -f "/root/escort-project/client/public/index.html" ]; then
  cp "/root/escort-project/client/public/index.html" "/root/escort-project/client/public/index.html.bak_sw"
  
  # Добавляем скрипт перед закрывающим тегом head
  sed -i '/<\/head>/i \    <script src="%PUBLIC_URL%/sw-disable.js"></script>' "/root/escort-project/client/public/index.html"
  
  echo "✅ Скрипт отключения ServiceWorker добавлен в index.html"
else
  echo "⚠️ Файл index.html не найден"
fi

# Отключаем регистрацию ServiceWorker в index.tsx, если он там регистрируется
if [ -f "$INDEX_FILE" ]; then
  cp $INDEX_FILE ${INDEX_FILE}.bak_sw
  
  # Комментируем регистрацию ServiceWorker, если она есть
  sed -i '/serviceWorker.register/s/^/\/\/ /' "$INDEX_FILE"
  sed -i '/serviceWorker.unregister/s/^/\/\/ /' "$INDEX_FILE"
  
  echo "✅ Регистрация ServiceWorker отключена в index.tsx"
else
  echo "⚠️ Файл index.tsx не найден"
fi

# Если существует файл sw.js, создаем его резервную копию и заменяем на пустой
if [ -f "$SW_FILE" ]; then
  cp $SW_FILE ${SW_FILE}.bak
  
  # Заменяем содержимое на минимальный ServiceWorker, который ничего не делает
  cat > $SW_FILE << 'EOFINNER'
// Минимальный ServiceWorker, который ничего не делает
self.addEventListener('install', function(event) {
  console.log('ServiceWorker установлен, но отключен функционально');
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  console.log('ServiceWorker активирован, но отключен функционально');
  return self.clients.claim();
});

self.addEventListener('fetch', function(event) {
  // Просто пропускаем запросы без перехвата
  return;
});
EOFINNER
  
  echo "✅ ServiceWorker заменен на минимальную версию"
else
  echo "⚠️ Файл sw.js не найден"
fi

echo "✅ Исправления ServiceWorker завершены"
