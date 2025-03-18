(function() {
  // Проверяем поддержку Service Worker
  if ('serviceWorker' in navigator) {
    // Находим все регистрации Service Worker и удаляем их
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
      console.log("Найдено регистраций Service Worker:", registrations.length);
      if (registrations.length > 0) {
        for(let registration of registrations) {
          registration.unregister();
          console.log('Service Worker отключен:', registration);
        }
        // Перезагружаем страницу чтобы убедиться что SW больше не работает
        if (window.caches) {
          caches.keys().then(function(names) {
            for (let name of names) {
              caches.delete(name);
              console.log('Кэш удален:', name);
            }
          });
        }
        console.log("Все регистрации Service Worker удалены");
      }
    }).catch(function(error) {
      console.log('Ошибка при отключении Service Worker:', error);
    });

    // Переопределяем метод register для предотвращения регистрации новых Service Worker
    const originalRegister = navigator.serviceWorker.register;
    navigator.serviceWorker.register = function() {
      console.warn('🛑 Попытка регистрации Service Worker заблокирована');
      return Promise.reject(new Error('Регистрация Service Worker отключена'));
    };
    
    console.log('Регистрация Service Worker заблокирована');
  }
})();
