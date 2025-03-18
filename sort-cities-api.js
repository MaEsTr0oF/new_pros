/**
 * Скрипт для перехвата и модификации API-ответов с городами
 */
(function() {
  // Перехватываем оригинальный метод fetch
  const originalFetch = window.fetch;
  
  window.fetch = async function(resource, init) {
    // Вызываем оригинальный fetch
    const response = await originalFetch(resource, init);
    
    // Клонируем ответ, так как его можно прочитать только один раз
    const clone = response.clone();
    
    // Проверяем, является ли запрос запросом городов
    if (typeof resource === 'string' && resource.includes('/api/cities')) {
      try {
        // Получаем данные из ответа
        const data = await clone.json();
        
        // Проверяем, что данные - массив
        if (Array.isArray(data)) {
          // Сортируем города по алфавиту
          const sortedData = [...data].sort((a, b) => {
            // Предполагаем, что город имеет свойство 'name'
            return a.name.localeCompare(b.name, 'ru');
          });
          
          console.log('API-ответ с городами отсортирован по алфавиту:', sortedData);
          
          // Создаем новый Response с отсортированными данными
          return new Response(JSON.stringify(sortedData), {
            status: response.status,
            statusText: response.statusText,
            headers: response.headers
          });
        }
      } catch (error) {
        console.error('Ошибка при сортировке городов:', error);
      }
    }
    
    // Если это не запрос городов или произошла ошибка, возвращаем оригинальный ответ
    return response;
  };
  
  // Также перехватываем axios, если он используется
  if (window.axios) {
    const originalGet = window.axios.get;
    
    window.axios.get = async function(url, config) {
      try {
        // Вызываем оригинальный axios.get
        const response = await originalGet(url, config);
        
        // Проверяем, является ли запрос запросом городов
        if (typeof url === 'string' && url.includes('/api/cities')) {
          // Проверяем, что data - массив
          if (Array.isArray(response.data)) {
            // Сортируем города по алфавиту
            response.data.sort((a, b) => a.name.localeCompare(b.name, 'ru'));
            console.log('Axios API-ответ с городами отсортирован по алфавиту:', response.data);
          }
        }
        
        return response;
      } catch (error) {
        throw error;
      }
    };
  }
  
  console.log('Установлен перехватчик API-запросов для сортировки городов');
})();
