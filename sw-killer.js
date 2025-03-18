// Скрипт для полного отключения ServiceWorker
(function() {
  // Блокируем регистрацию ServiceWorker
  Object.defineProperty(navigator, 'serviceWorker', {
    get: function() {
      console.log('Попытка доступа к ServiceWorker заблокирована');
      return {
        register: function() {
          console.log('Регистрация ServiceWorker заблокирована');
          return Promise.resolve(null);
        },
        getRegistrations: function() {
          console.log('Получение регистраций ServiceWorker заблокировано');
          return Promise.resolve([]);
        },
        ready: Promise.resolve(null)
      };
    },
    configurable: false
  });
  
  // Очищаем кэш
  if ('caches' in window) {
    caches.keys().then(function(names) {
      names.forEach(function(name) {
        console.log('Очистка кэша:', name);
        caches.delete(name);
      });
    });
  }
  
  console.log('ServiceWorker полностью отключен');
})();
