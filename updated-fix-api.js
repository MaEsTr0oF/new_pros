// Скрипт который перезаписывает API URL
(function() {
  // Переопределение API_URL в глобальном контексте
  window.API_URL = 'http://77.73.235.201/api';
  console.log('API_URL принудительно изменен на: http://77.73.235.201/api');
  
  // Отслеживаем все запросы, предотвращая ошибки
  window.addEventListener('error', function(e) {
    if (e && e.target && (e.target.tagName === 'SCRIPT' || e.target.tagName === 'IMG')) {
      console.log('Перехвачена ошибка загрузки ресурса:', e.target.src);
      e.preventDefault();
    }
  }, true);
  
  // Перехватываем все fetch запросы
  const originalFetch = window.fetch;
  window.fetch = function(url, options) {
    if (typeof url === 'string' && url.includes('eskortvsegorodarfreal.site/api')) {
      url = url.replace('https://eskortvsegorodarfreal.site/api', 'http://77.73.235.201/api');
      console.log('Fetch URL изменен на:', url);
    }
    return originalFetch.call(this, url, options);
  };

  // Перехват и изменение URL во всех API запросах
  if (window.XMLHttpRequest) {
    var originalOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
      if (typeof url === 'string' && url.includes('eskortvsegorodarfreal.site/api')) {
        url = url.replace('https://eskortvsegorodarfreal.site/api', 'http://77.73.235.201/api');
        console.log('XMLHttpRequest URL изменен на:', url);
      }
      return originalOpen.call(this, method, url, async, user, password);
    };
  }
  
  // Ждем загрузки axios и меняем его baseURL
  var checkAxios = setInterval(function() {
    if (window.axios) {
      console.log('Перехват axios, изменение baseURL');
      window.axios.defaults.baseURL = 'http://77.73.235.201/api';
      
      // Добавляем перехватчик запросов
      window.axios.interceptors.request.use(function(config) {
        console.log('Axios запрос:', config.url);
        return config;
      });
      
      clearInterval(checkAxios);
    }
  }, 100);
})();
