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
