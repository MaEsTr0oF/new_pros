// Заглушка для API городов
(function() {
  console.log('Заглушка API городов загружена');
  
  // Перехватываем запросы к API городов
  const originalFetch = window.fetch;
  window.fetch = function(url, options) {
    // Проверяем URL запроса
    if (typeof url === 'string') {
      // Запросы на создание, обновление или удаление города
      if (url.includes('/api/admin/cities')) {
        console.log('Перехват запроса к API городов:', url, options?.method || 'GET');
        
        // Эмулируем успешный ответ
        return new Promise(resolve => {
          setTimeout(() => {
            // Создаем ответ в зависимости от метода
            let responseData;
            
            if (options?.method === 'POST') {
              // Создание города
              console.log('Эмуляция создания города');
              const body = options.body ? JSON.parse(options.body) : {};
              responseData = {
                id: Date.now(),
                name: body.name || 'Новый город',
                code: body.code || 'new-city'
              };
            } else if (options?.method === 'PUT') {
              // Обновление города
              console.log('Эмуляция обновления города');
              const cityId = url.split('/').pop();
              const body = options.body ? JSON.parse(options.body) : {};
              responseData = {
                id: Number(cityId),
                name: body.name || 'Обновленный город',
                code: body.code || 'updated-city'
              };
            } else if (options?.method === 'DELETE') {
              // Удаление города
              console.log('Эмуляция удаления города');
              const cityId = url.split('/').pop();
              responseData = {
                message: 'Город успешно удален',
                city: {
                  id: Number(cityId),
                  name: 'Удаленный город',
                  code: 'deleted-city'
                }
              };
            }
            
            // Создаем объект Response
            const response = new Response(JSON.stringify(responseData), {
              status: 200,
              headers: {
                'Content-Type': 'application/json'
              }
            });
            
            resolve(response);
          }, 300);
        });
      }
    }
    
    // Для других запросов используем оригинальный fetch
    return originalFetch(url, options);
  };
  
  // Перехватываем запросы Axios, если он используется
  if (window.axios) {
    // Перехват POST запросов
    const originalPost = window.axios.post;
    window.axios.post = function(url, data, config) {
      if (url.includes('/api/admin/cities')) {
        console.log('Перехват Axios POST запроса к API городов:', url);
        
        return new Promise(resolve => {
          setTimeout(() => {
            const responseData = {
              id: Date.now(),
              name: data.name || 'Новый город',
              code: data.code || 'new-city'
            };
            
            resolve({
              data: responseData,
              status: 200,
              statusText: 'OK',
              headers: {},
              config
            });
          }, 300);
        });
      }
      
      return originalPost(url, data, config);
    };
    
    // Перехват PUT запросов
    const originalPut = window.axios.put;
    window.axios.put = function(url, data, config) {
      if (url.includes('/api/admin/cities')) {
        console.log('Перехват Axios PUT запроса к API городов:', url);
        
        return new Promise(resolve => {
          setTimeout(() => {
            const cityId = url.split('/').pop();
            const responseData = {
              id: Number(cityId),
              name: data.name || 'Обновленный город',
              code: data.code || 'updated-city'
            };
            
            resolve({
              data: responseData,
              status: 200,
              statusText: 'OK',
              headers: {},
              config
            });
          }, 300);
        });
      }
      
      return originalPut(url, data, config);
    };
    
    // Перехват DELETE запросов
    const originalDelete = window.axios.delete;
    window.axios.delete = function(url, config) {
      if (url.includes('/api/admin/cities')) {
        console.log('Перехват Axios DELETE запроса к API городов:', url);
        
        return new Promise(resolve => {
          setTimeout(() => {
            const cityId = url.split('/').pop();
            const responseData = {
              message: 'Город успешно удален',
              city: {
                id: Number(cityId),
                name: 'Удаленный город',
                code: 'deleted-city'
              }
            };
            
            resolve({
              data: responseData,
              status: 200,
              statusText: 'OK',
              headers: {},
              config
            });
          }, 300);
        });
      }
      
      return originalDelete(url, config);
    };
  }
})();
