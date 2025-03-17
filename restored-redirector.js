/**
 * Скрипт для перенаправления всех HTTP запросов на HTTPS
 * Решает проблему Mixed Content в браузере
 */
(function() {
  // Перехватываем XMLHttpRequest для переадресации HTTP на HTTPS        
  const originalXHROpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
    // Преобразуем URL из HTTP в HTTPS, если домен совпадает
    let modifiedUrl = url;
    if (typeof url === 'string' && url.startsWith('http://') && url.includes('eskortvsegorodarfreal.site')) {
      modifiedUrl = url.replace('http://', 'https://');
      console.info('XMLHttpRequest URL перенаправлен с HTTP на HTTPS:', url, '->', modifiedUrl);
    }
    return originalXHROpen.call(this, method, modifiedUrl, async, user, password);
  };

  // Перехватываем fetch для переадресации HTTP на HTTPS
  const originalFetch = window.fetch;
  window.fetch = function(input, init) {
    if (typeof input === 'string' && input.startsWith('http://') && input.includes('eskortvsegorodarfreal.site')) {
      const modifiedInput = input.replace('http://', 'https://');        
      console.info('Fetch URL перенаправлен с HTTP на HTTPS:', input, '->', modifiedInput);
      return originalFetch.call(this, modifiedInput, init);
    }
    return originalFetch.call(this, input, init);
  };

  // Установим переменную API_URL в глобальном контексте
  window.API_URL = 'https://eskortvsegorodarfreal.site/api';
  console.info('API_URL установлен как:', window.API_URL);

  // Регистрация Service Worker для перехвата сетевых запросов (если браузер поддерживает)
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
      navigator.serviceWorker.register('/sw.js')
        .then(function(registration) {
          console.info('ServiceWorker зарегистрирован успешно:', registration.scope);
        })
        .catch(function(error) {
          console.error('Ошибка регистрации ServiceWorker:', error);     
        });
    });
  }
})();
