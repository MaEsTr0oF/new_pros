// Скрипт для перехвата и исправления API-запросов
(function() {
  console.log('Скрипт перехвата API-запросов загружен');
  
  // Перенаправляем запросы districts и services на наш прокси-сервер
  const originalFetch = window.fetch;
  window.fetch = function(url, options) {
    // Проверяем URL запроса
    if (typeof url === 'string') {
      // Запросы к API districts/:cityId
      if (url.match(/\/api\/districts\/\d+/)) {
        const cityId = url.split('/').pop();
        console.log(`Перенаправляем запрос districts для города ${cityId} на прокси-сервер`);
        return originalFetch(`http://77.73.235.201:3000/api/districts/${cityId}`, options);
      }
      
      // Запросы к API services
      if (url === '/api/services' || url.endsWith('/api/services')) {
        console.log('Перенаправляем запрос services на прокси-сервер');
        return originalFetch('http://77.73.235.201:3000/api/services', options);
      }
    }
    
    // Для других запросов используем оригинальный fetch
    return originalFetch(url, options);
  };
  
  // Перехватываем запросы Axios
  if (window.axios) {
    const originalAxiosGet = window.axios.get;
    window.axios.get = function(url, config) {
      // Проверяем URL запроса
      if (typeof url === 'string') {
        // Запросы к API districts/:cityId
        if (url.match(/\/api\/districts\/\d+/)) {
          const cityId = url.split('/').pop();
          console.log(`Перенаправляем Axios запрос districts для города ${cityId} на прокси-сервер`);
          return originalAxiosGet(`http://77.73.235.201:3000/api/districts/${cityId}`, config);
        }
        
        // Запросы к API services
        if (url === '/api/services' || url.endsWith('/api/services')) {
          console.log('Перенаправляем Axios запрос services на прокси-сервер');
          return originalAxiosGet('http://77.73.235.201:3000/api/services', config);
        }
      }
      
      // Для других запросов используем оригинальный Axios.get
      return originalAxiosGet(url, config);
    };
  }
  
  console.log('Перехватчик API-запросов настроен');
})();
