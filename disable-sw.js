// Этот скрипт полностью отключает Service Worker
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(function(registrations) {
    for(let registration of registrations) {
      registration.unregister();
      console.log('Service Worker отменен:', registration);
    }
  });
}

// Отменяем перехват XHR и fetch
window.addEventListener('DOMContentLoaded', function() {
  // Принудительно переключаем на HTTP
  window.API_URL = 'http://eskortvsegorodarfreal.site/api';
  console.log('API_URL установлен на:', window.API_URL);
  
  // Если есть axios, меняем его базовый URL
  if (window.axios) {
    window.axios.defaults.baseURL = 'http://eskortvsegorodarfreal.site/api';
    console.log('Axios baseURL изменен на:', window.axios.defaults.baseURL);
  }
});
