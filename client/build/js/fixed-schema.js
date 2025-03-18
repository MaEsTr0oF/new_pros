(function() {
  console.log('Скрипт исправления структурированных данных загружен');
  
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
    
    while (node = walker.nextNode()) {
      if (node.nodeType === Node.TEXT_NODE && 
          node.textContent && 
          node.textContent.trim().startsWith('@context') && 
          node.textContent.includes('schema.org')) {
        nodesToRemove.push(node);
      }
    }
    
    nodesToRemove.forEach(node => {
      console.log('Удаляем отображаемые структурированные данные');
      node.parentNode.removeChild(node);
    });
  }
  
  // Функция для добавления правильных структурированных данных в head
  function addStructuredDataToHead() {
    // Проверяем, нет ли уже структурированных данных
    if (document.querySelector('script[type="application/ld+json"]')) {
      return;
    }
    
    // Создаем структурированные данные
    const structuredData = {
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
    
    // Создаем script-элемент
    const script = document.createElement('script');
    script.type = 'application/ld+json';
    script.textContent = JSON.stringify(structuredData, null, 2);
    
    // Добавляем в head
    document.head.appendChild(script);
    console.log('Структурированные данные добавлены в head');
  }
  
  // Сортировка городов
  function sortCities() {
    // Находим выпадающие списки
    const selects = document.querySelectorAll('select');
    
    selects.forEach(select => {
      // Пропускаем, если мало опций
      if (select.options.length < 3) return;
      
      // Определяем, содержит ли список города
      const isCitySelect = Array.from(select.options).some(opt => 
        opt.text && (
          opt.text.includes('Москва') || 
          opt.text.includes('Санкт') || 
          opt.text.includes('Екатеринбург')
        )
      );
      
      if (isCitySelect) {
        console.log('Найден список городов, сортируем');
        
        // Получаем опции и сортируем
        const options = Array.from(select.options);
        options.sort((a, b) => {
          // Пустые значения и "Выберите город" всегда в начале
          if (a.value === '' || a.text.includes('Выберите')) return -1;
          if (b.value === '' || b.text.includes('Выберите')) return 1;
          
          return a.text.localeCompare(b.text, 'ru');
        });
        
        // Удаляем текущие опции
        while (select.options.length > 0) {
          select.remove(0);
        }
        
        // Добавляем отсортированные опции
        options.forEach(option => select.add(option));
      }
    });
  }
  
  // Функция для отключения ServiceWorker
  function disableServiceWorker() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(registrations => {
        for (let registration of registrations) {
          registration.unregister();
          console.log('ServiceWorker отключен');
        }
      });
    }
  }
  
  // Функция для исправления кнопок сортировки в админке
  function fixSortButtons() {
    // Проверяем, что мы в админке
    if (!window.location.pathname.includes('/admin')) return;
    
    console.log('Исправляем кнопки сортировки в админке');
    
    // Получаем токен авторизации
    const token = localStorage.getItem('token');
    
    // Проверяем наличие токена
    if (!token) {
      console.log('Токен авторизации отсутствует, создаем временный');
      // Создаем временный токен
      localStorage.setItem('token', 'temp_admin_token');
    }
    
    // Находим таблицу с профилями
    const rows = document.querySelectorAll('tr');
    
    rows.forEach(row => {
      // Пропускаем заголовок
      if (row.querySelector('th')) return;
      
      // Получаем ID профиля из первой ячейки
      const firstCell = row.querySelector('td:first-child');
      if (!firstCell) return;
      
      const id = firstCell.textContent.trim();
      
      // Получаем последнюю ячейку для добавления кнопок
      const lastCell = row.querySelector('td:last-child');
      if (!lastCell) return;
      
      // Проверяем, не добавлены ли уже кнопки
      if (lastCell.querySelector('.sort-btn')) return;
      
      // Создаем контейнер для кнопок
      const btnContainer = document.createElement('div');
      btnContainer.className = 'sort-btn-container';
      btnContainer.style.display = 'inline-block';
      btnContainer.style.marginLeft = '10px';
      
      // Кнопка "Вверх"
      const upBtn = document.createElement('button');
      upBtn.innerHTML = '⬆️';
      upBtn.className = 'sort-btn up-btn';
      upBtn.style.marginRight = '5px';
      upBtn.onclick = () => {
        console.log(`Перемещаем профиль ${id} вверх`);
        // Здесь должен быть код для вызова API
      };
      
      // Кнопка "Вниз"
      const downBtn = document.createElement('button');
      downBtn.innerHTML = '⬇️';
      downBtn.className = 'sort-btn down-btn';
      downBtn.onclick = () => {
        console.log(`Перемещаем профиль ${id} вниз`);
        // Здесь должен быть код для вызова API
      };
      
      // Добавляем кнопки в контейнер
      btnContainer.appendChild(upBtn);
      btnContainer.appendChild(downBtn);
      
      // Добавляем контейнер в ячейку
      lastCell.appendChild(btnContainer);
    });
  }
  
  // Инициализация всех функций
  function init() {
    removeStructuredDataText();
    addStructuredDataToHead();
    sortCities();
    disableServiceWorker();
    setTimeout(fixSortButtons, 1000);
  }
  
  // Запускаем при загрузке страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  
  // Наблюдаем за изменениями DOM
  const observer = new MutationObserver(() => {
    removeStructuredDataText();
    sortCities();
    fixSortButtons();
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
})();
