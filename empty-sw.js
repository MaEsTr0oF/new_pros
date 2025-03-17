// Пустой Service Worker для отмены работы предыдущего
self.addEventListener('install', event => {
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  // Очищаем все кэши, созданные предыдущей версией
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          return caches.delete(cacheName);
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Не перехватываем никакие запросы
self.addEventListener('fetch', event => {
  event.respondWith(fetch(event.request));
});
