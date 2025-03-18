(function() {
  console.log('Скрипт исправления структурированных данных запущен');
  
  // Функция для удаления отображаемых структурированных данных
  function removeStructuredDataText() {
    // Находим все текстовые узлы в body
    const walker = document.createTreeWalker(
      document.body,
      NodeFilter.SHOW_TEXT,
      null,
      false
    );
    
    const nodesToRemove = [];
    let node;
    
    // Собираем все текстовые узлы, содержащие schema.org
    while (node = walker.nextNode()) {
      // Проверяем наличие структурированных данных в тексте
      if (node.textContent && 
          node.textContent.includes('@context') && 
          node.textContent.includes('schema.org')) {
        nodesToRemove.push(node);
      }
    }
    
    // Удаляем найденные узлы
    nodesToRemove.forEach(node => {
      console.log('Удаляем неправильно отображаемые структурированные данные');
      node.parentNode.removeChild(node);
    });
    
    // Добавляем правильные структурированные данные в head, если их еще нет
    if (!document.querySelector('script[type="application/ld+json"]')) {
      const schemaData = {
        "@context": "https://schema.org",
        "@type": "WebSite",
        "name": "Эскорт услуги в России",
        "url": "https://eskortvsegorodarfreal.site",
        "potentialAction": {
          "@type": "SearchAction",
          "target": "https://eskortvsegorodarfreal.site/?search={search_term_string}",
          "query-input": "required name=search_term_string"
        }
      };
      
      const script = document.createElement('script');
      script.type = 'application/ld+json';
      script.textContent = JSON.stringify(schemaData, null, 2);
      document.head.appendChild(script);
      console.log('Структурированные данные добавлены в head');
    }
  }
  
  // Функция для сортировки городов
  function sortCities() {
    // Находим все выпадающие списки на странице
    const selects = document.querySelectorAll('select');
    
    selects.forEach(select => {
      // Пропускаем, если меньше 3 опций
      if (select.options.length < 3) return;
      
      // Проверяем, содержит ли этот список города
      const options = Array.from(select.options);
      const cityNames = options.map(opt => opt.text.toLowerCase());
      
      const containsRussianCities = cityNames.some(name => 
        name.includes('москва') || 
        name.includes('санкт') || 
        name.includes('екатер') ||
        name.includes('воронеж') ||
        name.includes('казань')
      );
      
      if (containsRussianCities) {
        console.log('Найден список городов, выполняем сортировку');
        
        // Сохраняем выбранное значение
        const selectedValue = select.value;
        
        // Сортируем опции по тексту
        options.sort((a, b) => {
          // Пустые или "Выберите" опции всегда в начале
          if (a.value === '' || a.text.includes('Выберите')) return -1;
          if (b.value === '' || b.text.includes('Выберите')) return 1;
          
          return a.text.localeCompare(b.text, 'ru');
        });
        
        // Удаляем все опции из селекта
        while (select.options.length > 0) {
          select.remove(0);
        }
        
        // Добавляем отсортированные опции обратно
        options.forEach(option => {
          select.add(option);
        });
        
        // Восстанавливаем выбранное значение
        if (selectedValue) {
          select.value = selectedValue;
        }
        
        console.log('Города отсортированы по алфавиту');
      }
    });
  }
  
  // Отключаем ServiceWorker
  function disableServiceWorker() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(function(registrations) {
        for (let registration of registrations) {
          registration.unregister().then(function(success) {
            console.log('ServiceWorker отключен:', success);
          });
        }
      });
    }
  }
  
  // Выполняем функции при загрузке страницы
  function init() {
    console.log('Инициализация скриптов исправлений');
    
    // Отключаем ServiceWorker
    disableServiceWorker();
    
    // Удаляем неправильно отображаемые структурированные данные
    removeStructuredDataText();
    
    // Сортируем города
    sortCities();
    
    // Повторяем с задержкой для динамически загружаемого контента
    setTimeout(removeStructuredDataText, 500);
    setTimeout(sortCities, 500);
    setTimeout(removeStructuredDataText, 1500);
    setTimeout(sortCities, 1500);
  }
  
  // Запускаем при загрузке страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  
  // Наблюдаем за изменениями DOM
  const observer = new MutationObserver(function() {
    removeStructuredDataText();
    sortCities();
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
})();
