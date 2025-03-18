(function() {
  // Отключаем Service Worker
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
      for (let registration of registrations) {
        registration.unregister();
        console.log('Service Worker отключен');
      }
    });
    
    // Перехватываем попытки регистрации нового Service Worker
    const originalRegister = navigator.serviceWorker.register;
    navigator.serviceWorker.register = function() {
      console.warn('Попытка регистрации Service Worker предотвращена');
      return Promise.reject(new Error('Регистрация Service Worker отключена'));
    };
  }
})();
