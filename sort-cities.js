/**
 * Скрипт для сортировки городов по алфавиту в выпадающих списках
 */
(function() {
  // Функция для сортировки городов в выпадающем списке
  function sortCitiesInDropdown() {
    // Ждем загрузки данных городов
    const checkInterval = setInterval(() => {
      // Проверяем наличие выпадающих списков городов
      const selects = document.querySelectorAll('select, ul');

      selects.forEach(select => {
        const options = select.querySelectorAll('option, li');
        
        // Если найдено более 3 опций, значит это может быть список городов
        if (options.length > 3) {
          const optionsArray = Array.from(options);
          
          // Проверяем, похоже ли это на список городов
          const isCityList = optionsArray.some(opt => 
            opt.textContent.includes('Москва') || 
            opt.textContent.includes('Санкт-Петербург') ||
            opt.textContent.includes('Казань')
          );
          
          if (isCityList) {
            console.log('Найден список городов для сортировки:', select);
            
            // Сортируем опции по алфавиту (оставляя первую опцию как есть, если это заголовок)
            const startIndex = optionsArray[0].value === '' ? 1 : 0;
            const sortedOptions = [
              ...optionsArray.slice(0, startIndex),
              ...optionsArray.slice(startIndex).sort((a, b) => 
                a.textContent.localeCompare(b.textContent, 'ru')
              )
            ];
            
            // Применяем отсортированный порядок
            sortedOptions.forEach(option => {
              select.appendChild(option);
            });
            
            console.log('Города отсортированы по алфавиту');
          }
        }
      });
    }, 1000);
    
    // Остановим проверку через 10 секунд
    setTimeout(() => {
      clearInterval(checkInterval);
    }, 10000);
  }
  
  // Функция для сортировки городов в администраторской панели
  function sortCitiesInAdminPanel() {
    // Ждем загрузки таблицы городов в админке
    const checkInterval = setInterval(() => {
      const tables = document.querySelectorAll('table');
      
      tables.forEach(table => {
        // Проверяем, является ли таблица списком городов
        const headers = table.querySelectorAll('th');
        const isCityTable = Array.from(headers).some(h => 
          h.textContent.includes('Город') || h.textContent.includes('Название')
        );
        
        if (isCityTable) {
          console.log('Найдена таблица городов для сортировки:', table);
          
          const tbody = table.querySelector('tbody');
          if (tbody) {
            const rows = Array.from(tbody.querySelectorAll('tr'));
            
            // Сортируем строки по первой или второй колонке (где обычно находится название города)
            const sortedRows = rows.sort((a, b) => {
              const aText = a.cells[1]?.textContent || a.cells[0]?.textContent || '';
              const bText = b.cells[1]?.textContent || b.cells[0]?.textContent || '';
              return aText.localeCompare(bText, 'ru');
            });
            
            // Применяем отсортированный порядок
            sortedRows.forEach(row => {
              tbody.appendChild(row);
            });
            
            console.log('Таблица городов отсортирована по алфавиту');
          }
        }
      });
    }, 1000);
    
    // Остановим проверку через 20 секунд
    setTimeout(() => {
      clearInterval(checkInterval);
    }, 20000);
  }
  
  // Запускаем сортировку при загрузке страницы
  window.addEventListener('load', () => {
    sortCitiesInDropdown();
    
    // Проверяем, находимся ли мы в админке
    if (window.location.pathname.includes('/admin')) {
      sortCitiesInAdminPanel();
    }
    
    // Наблюдаем за изменениями в DOM для повторной сортировки при динамической загрузке
    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
          // При добавлении новых элементов снова запускаем сортировку
          sortCitiesInDropdown();
          if (window.location.pathname.includes('/admin')) {
            sortCitiesInAdminPanel();
          }
        }
      }
    });
    
    observer.observe(document.body, { childList: true, subtree: true });
  });
})();
