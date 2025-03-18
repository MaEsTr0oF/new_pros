// Отключение существующего Service Worker
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(function(registrations) {
    for (let registration of registrations) {
      registration.unregister();
      console.log('Service Worker unregistered');
    }
    // После отключения всех Service Worker перезагрузим страницу
    if (registrations.length > 0) {
      window.location.reload();
    }
  });
}

// Блокировка запуска Service Worker в будущем
if (window.navigator && navigator.serviceWorker) {
  navigator.serviceWorker.register = function() {
    return new Promise(function(resolve) {
      console.log('Service Worker registration blocked');
      resolve({ scope: '/' });
    });
  };
}
