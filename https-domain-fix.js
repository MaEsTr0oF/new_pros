// Скрипт определения текущего хоста для HTTPS
(function() {
  // Определяем, откуда загружена страница
  var currentHost = window.location.hostname;
  var currentProtocol = window.location.protocol;
  console.log('Страница загружена с: ' + currentProtocol + '//' + currentHost);
  
  // Устанавливаем API_URL с тем же протоколом, что и страница
  var apiUrl = currentProtocol + '//' + currentHost + '/api';
  console.log('API_URL устанавливается на: ' + apiUrl);
  
  // Глобальное переопределение API_URL
  window.API_URL = apiUrl;
  
  // Подавляем другие скрипты
  const originalDefineProperty = Object.defineProperty;
  Object.defineProperty = function(obj, prop, descriptor) {
    if (prop === 'API_URL' && obj === window) {
      console.log('Блокирование попытки переопределить API_URL');
      return obj;
    }
    return originalDefineProperty(obj, prop, descriptor);
  };
  
  // Перехватываем axios для установки правильного baseURL
  function setupAxios() {
    if (window.axios) {
      console.log('Настройка axios baseURL на: ' + apiUrl);
      window.axios.defaults.baseURL = apiUrl;
      
      // Перехватчик axios запросов
      window.axios.interceptors.request.use(function(config) {
        // Убедимся, что все URL имеют тот же протокол, что и страница
        if (config.url && config.url.startsWith('http:') && currentProtocol === 'https:') {
          config.url = config.url.replace('http:', 'https:');
        }
        return config;
      });
    } else {
      setTimeout(setupAxios, 100);  // Проверяем снова через 100ms
    }
  }
  
  // Ожидаем загрузку DOM и выполняем настройку axios
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupAxios);
  } else {
    setupAxios();
  }
  
  // Перехватываем XMLHttpRequest для изменения всех URL на HTTPS
  var originalOpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
    if (typeof url === 'string' && url.startsWith('http:') && currentProtocol === 'https:') {
      url = url.replace('http:', 'https:');
      console.log('XMLHttpRequest URL изменен на: ' + url);
    }
    return originalOpen.call(this, method, url, async, user, password);
  };
})();
