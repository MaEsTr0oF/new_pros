(function() {
  // Функция для перемещения структурированных данных в head документа
  function fixStructuredData() {
    // Ищем все элементы script с типом application/ld+json
    const jsonScripts = document.querySelectorAll('script[type="application/ld+json"]');
    
    // Если найдены JSON скрипты в неправильном месте
    if (jsonScripts.length > 0) {
      console.log("Найдены структурированные данные, перемещаем в head...");
      
      // Перемещаем каждый скрипт в head
      jsonScripts.forEach(script => {
        // Копируем содержимое скрипта
        const content = script.textContent;
        const type = script.type;
        
        // Создаем новый скрипт в head
        const newScript = document.createElement('script');
        newScript.type = type;
        newScript.textContent = content;
        
        // Добавляем в head
        document.head.appendChild(newScript);
        
        // Удаляем оригинальный скрипт
        script.parentNode.removeChild(script);
      });
      
      console.log("Структурированные данные успешно перенесены в head.");
    }
  }
  
  // Запускаем исправление после загрузки страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fixStructuredData);
  } else {
    fixStructuredData();
  }
})();
