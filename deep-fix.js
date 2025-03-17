// Скрипт глубокой фиксации API URL
(function() {
  console.log('Запущен скрипт глубокой фиксации API URL');
  
  // Переопределение window.location для предотвращения редиректов
  const originalAssign = window.location.assign;
  window.location.assign = function(url) {
    if (url.includes('https://eskortvsegorodarfreal.site')) {
      url = url.replace('https://eskortvsegorodarfreal.site', 'http://77.73.235.201');
      console.log('Перехвачен редирект на:', url);
    }
    return originalAssign.call(window.location, url);
  };
  
  // Глобальное переопределение config.ts
  Object.defineProperty(window, 'API_URL', {
    value: 'http://77.73.235.201/api',
    writable: false,
    configurable: false
  });
  
  // Перехват всех сетевых запросов и переадресация
  window.addEventListener('DOMContentLoaded', function() {
    console.log('DOMContentLoaded: начинаем мониторинг API запросов');
    
    // Модификация axios (самый надежный способ)
    setInterval(function() {
      if (window.axios && !window._axiosPatched) {
        window._axiosPatched = true;
        console.log('Найден axios - применяем патчи');
        
        // Установка базового URL
        window.axios.defaults.baseURL = 'http://77.73.235.201/api';
        
        // Перехват запросов
        window.axios.interceptors.request.use(function(config) {
          if (config.url && config.url.includes('eskortvsegorodarfreal.site')) {
            config.url = config.url.replace('https://eskortvsegorodarfreal.site', 'http://77.73.235.201');
          }
          return config;
        });
        
        // Повторим попытку загрузки данных
        console.log('Обновляем страницу для применения изменений');
        setTimeout(function() {
          window.location.reload();
        }, 500);
      }
    }, 100);
  });
})();
