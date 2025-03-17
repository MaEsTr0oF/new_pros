/**
 * Service Worker для кэширования ресурсов и перенаправления HTTP на HTTPS
 */

const CACHE_NAME = 'escort-v1';
const URLS_TO_CACHE = [
  '/',
  '/index.html',
  '/static/js/main.js',
  '/static/css/main.css',
  '/manifest.json',
  '/logo192.png',
  '/logo512.png',
  '/favicon.ico',
  '/robots.txt',
  '/sitemap.xml',
  '/https-redirector.js'
];

// Установка Service Worker и кэширование базовых ресурсов
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Кэширование ресурсов');
        return cache.addAll(URLS_TO_CACHE);
      })
  );
});

// Очистка старых кэшей при активации
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Удаление старого кэша:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Обработка запросов с проверкой кэша и перенаправление HTTP на HTTPS
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // Перенаправляем HTTP на HTTPS, если домен совпадает
  if (url.protocol === 'http:' && url.hostname === 'eskortvsegorodarfreal.site') {
    const secureUrl = event.request.url.replace('http://', 'https://');
    console.log('SW перенаправил запрос с HTTP на HTTPS:', event.request.url, '->', secureUrl);
    event.respondWith(fetch(secureUrl, { 
      redirect: 'follow',
      headers: event.request.headers
    }));
    return;
  }
  
  // Стратегия сначала сеть, потом кэш
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // Не кэшируем ответы от API
        if (url.pathname.startsWith('/api/')) {
          return response;
        }
        
        // Создаем копию ответа для кэширования
        const responseToCache = response.clone();
        caches.open(CACHE_NAME)
          .then(cache => {
            // Кэшируем только успешные ответы
            if (event.request.method === 'GET' && response.status === 200) {
              cache.put(event.request, responseToCache);
            }
          });
        return response;
      })
      .catch(() => {
        // При ошибке сети используем кэш
        return caches.match(event.request);
      })
  );
}); 