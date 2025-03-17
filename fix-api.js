// Скрипт который перезаписывает API URL
(function() {
  // Переопределение API_URL в глобальном контексте
  window.API_URL = 'http://77.73.235.201/api';
  console.log('API_URL принудительно изменен на: http://77.73.235.201/api');
  
  // Перехват и изменение URL во всех API запросах
  if (window.XMLHttpRequest) {
    var originalOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
      // Если URL содержит eskortvsegorodarfreal.site/api, заменяем его на IP
      if (typeof url === 'string' && url.includes('eskortvsegorodarfreal.site/api')) {
        url = url.replace('https://eskortvsegorodarfreal.site/api', 'http://77.73.235.201/api');
        console.log('XMLHttpRequest URL изменен на:', url);
      }
      return originalOpen.call(this, method, url, async, user, password);
    };
  }
  
  // Ждем загрузки axios и меняем его baseURL
  document.addEventListener('DOMContentLoaded', function() {
    var checkAxios = setInterval(function() {
      if (window.axios) {
        window.axios.defaults.baseURL = 'http://77.73.235.201/api';
        console.log('Axios baseURL изменен на: http://77.73.235.201/api');
        clearInterval(checkAxios);
      }
    }, 100);
  });
})();
