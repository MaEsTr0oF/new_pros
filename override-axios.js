// Скрипт, который перезаписывает все сетевые запросы
(function() {
  console.log('Скрипт перезаписи API URL загружен');
  
  // Принудительно меняем базовый URL для axios
  var checkAxios = setInterval(function() {
    if (window.axios) {
      console.log('axios найден, переопределяем baseURL');
      window.axios.defaults.baseURL = 'http://77.73.235.201/api';
      clearInterval(checkAxios);
      
      // Также пытаемся перехватить запросы
      window.axios.interceptors.request.use(function(config) {
        console.log('Перехват запроса:', config.url);
        
        // Заменяем URL на IP-адрес
        if (config.url.includes('eskortvsegorodarfreal.site')) {
          config.url = config.url.replace('eskortvsegorodarfreal.site', '77.73.235.201');
          console.log('URL изменен на:', config.url);
        }
        
        return config;
      });
    }
  }, 100);
  
  // Глобальная переменная API_URL
  window.API_URL = 'http://77.73.235.201/api';
  console.log('API_URL установлен как:', window.API_URL);
})();
