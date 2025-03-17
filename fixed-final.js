// Финальный скрипт исправления API URL
(function() {
  // Проверяем, был ли скрипт уже выполнен
  if (window.__apiUrlFixed) {
    console.log('Скрипт исправления API уже применен');
    return;
  }
  window.__apiUrlFixed = true;
  
  console.log('Запущен финальный скрипт исправления API URL');
  
  // Устанавливаем API_URL на текущий домен с тем же протоколом
  var currentHost = window.location.hostname;
  var currentProtocol = window.location.protocol;
  var apiUrl = currentProtocol + '//' + currentHost + '/api';
  console.log('API_URL установлен на: ' + apiUrl);
  
  // Блокируем старые скрипты и их попытки изменить URL
  window.API_URL = apiUrl;
  Object.defineProperty(window, 'API_URL', {
    value: apiUrl,
    writable: false,
    configurable: false
  });
  
  // Полностью заменяем XMLHttpRequest.open
  var originalOpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
    // Если URL содержит IP адрес, заменяем его на домен
    if (typeof url === 'string') {
      if (url.includes('77.73.235.201')) {
        url = url.replace('77.73.235.201', currentHost);
        console.log('XMLHttpRequest: заменен IP на домен', url);
      }
      
      // Если протокол не соответствует, исправляем
      if (currentProtocol === 'https:' && url.startsWith('http:')) {
        url = url.replace('http:', 'https:');
        console.log('XMLHttpRequest: исправлен протокол на HTTPS', url);
      }
    }
    
    return originalOpen.call(this, method, url, async, user, password);
  };
  
  // Перехватываем fetch
  var originalFetch = window.fetch;
  window.fetch = function(input, init) {
    if (typeof input === 'string') {
      if (input.includes('77.73.235.201')) {
        input = input.replace('77.73.235.201', currentHost);
        console.log('Fetch: заменен IP на домен', input);
      }
      
      if (currentProtocol === 'https:' && input.startsWith('http:')) {
        input = input.replace('http:', 'https:');
        console.log('Fetch: исправлен протокол на HTTPS', input);
      }
    }
    
    return originalFetch.call(this, input, init);
  };
  
  // Настройка axios
  document.addEventListener('DOMContentLoaded', function() {
    function setupAxios() {
      if (window.axios) {
        console.log('Axios найден, устанавливаем baseURL:', apiUrl);
        window.axios.defaults.baseURL = apiUrl;
        
        // Перехватчик для axios
        window.axios.interceptors.request.use(function(config) {
          if (config.url) {
            // Убираем IP адрес
            if (config.url.includes('77.73.235.201')) {
              config.url = config.url.replace('77.73.235.201', currentHost);
              console.log('Axios: IP заменен на домен', config.url);
            }
            
            // Исправляем протокол
            if (currentProtocol === 'https:' && config.url.startsWith('http:')) {
              config.url = config.url.replace('http:', 'https:');
              console.log('Axios: протокол изменен на HTTPS', config.url);
            }
          }
          return config;
        });
        clearInterval(axiosCheckInterval);
      }
    }
    
    // Периодическая проверка на axios
    var axiosCheckInterval = setInterval(setupAxios, 100);
  });
})();
