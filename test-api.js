// Скрипт для прямого тестирования API
(function() {
  console.log('Запущен диагностический скрипт API');
  
  // Функция для выполнения JSONP запроса
  function testApiEndpoint(endpoint) {
    console.log(`Тестирование эндпоинта: ${endpoint}`);
    
    // Создаем элемент для вывода результатов
    var resultDiv = document.createElement('div');
    resultDiv.style.position = 'fixed';
    resultDiv.style.top = '0';
    resultDiv.style.left = '0';
    resultDiv.style.width = '100%';
    resultDiv.style.backgroundColor = 'rgba(0,0,0,0.8)';
    resultDiv.style.color = 'white';
    resultDiv.style.padding = '10px';
    resultDiv.style.zIndex = '9999';
    resultDiv.style.maxHeight = '50vh';
    resultDiv.style.overflow = 'auto';
    resultDiv.style.fontFamily = 'monospace';
    resultDiv.innerHTML = '<h3>Тестирование API</h3>';
    document.body.appendChild(resultDiv);
    
    // Функция для добавления сообщения
    function log(message) {
      resultDiv.innerHTML += `<div>${message}</div>`;
    }
    
    // Тестируем разные варианты URL
    var urls = [
      `http://77.73.235.201:5001${endpoint}`,
      `http://escort-server:5001${endpoint}`,
      `http://77.73.235.201${endpoint}`,
      `http://localhost:5001${endpoint}`
    ];
    
    urls.forEach(function(url) {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', url, true);
      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
          log(`${url}: ${xhr.status} ${xhr.statusText}`);
          try {
            log(`Ответ: ${xhr.responseText.substring(0, 100)}...`);
          } catch(e) {
            log(`Ошибка чтения ответа: ${e.message}`);
          }
        }
      };
      xhr.onerror = function() {
        log(`${url}: Ошибка сети`);
      };
      xhr.send();
    });
  }
  
  // Запуск тестов по нажатию клавиши T
  document.addEventListener('keydown', function(e) {
    if (e.key.toLowerCase() === 't') {
      testApiEndpoint('/api/health');
      setTimeout(function() {
        testApiEndpoint('/api/cities');
      }, 1000);
    }
  });
  
  console.log('Нажмите T для тестирования API');
})();
