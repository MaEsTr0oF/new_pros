/**
 * Скрипт для отладки и мониторинга запросов к API городов
 */
(function() {
  console.log('Скрипт отладки городов загружен');
  
  // Проверяем работу с городами каждые 5 секунд
  setInterval(() => {
    fetch('/api/cities')
      .then(response => response.json())
      .then(cities => {
        // Проверяем, отсортированы ли города
        let sorted = true;
        for (let i = 1; i < cities.length; i++) {
          if (cities[i-1].name.localeCompare(cities[i].name, 'ru') > 0) {
            sorted = false;
            break;
          }
        }
        
        console.log('Получено городов:', cities.length);
        console.log('Города отсортированы по алфавиту:', sorted);
        
        if (!sorted) {
          console.warn('Города не отсортированы! Первые 5 городов:', cities.slice(0, 5).map(c => c.name));
        }
      })
      .catch(error => {
        console.error('Ошибка при запросе городов:', error);
      });
      
    // Проверяем маршрут districts
    fetch('/api/districts/1')
      .then(response => {
        console.log('Статус ответа /api/districts/1:', response.status);
        return response.json();
      })
      .then(districts => {
        console.log('Получены районы:', districts);
      })
      .catch(error => {
        console.error('Ошибка при запросе районов:', error);
      });
      
    // Проверяем маршрут services
    fetch('/api/services')
      .then(response => {
        console.log('Статус ответа /api/services:', response.status);
        return response.json();
      })
      .then(services => {
        console.log('Получены услуги:', services.length);
      })
      .catch(error => {
        console.error('Ошибка при запросе услуг:', error);
      });
  }, 5000);
})();
