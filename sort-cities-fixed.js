/**
 * Улучшенный скрипт для сортировки городов по алфавиту без циклического повторения
 */
(function() {
  // Маркер для отмеченных как отсортированные элементов
  const SORTED_ATTRIBUTE = 'data-cities-sorted';
  
  // Функция для сортировки городов в выпадающем списке
  function sortCitiesInDropdown() {
    // Ищем все селекты и списки, которые еще не были отсортированы
    const selects = document.querySelectorAll('select:not([' + SORTED_ATTRIBUTE + ']), ul:not([' + SORTED_ATTRIBUTE + '])');
    let found = false;
    
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
          
          // Помечаем элемент как отсортированный
          select.setAttribute(SORTED_ATTRIBUTE, 'true');
          
          console.log('Города отсортированы по алфавиту');
          found = true;
        }
      }
    });
    
    return found;
  }
  
  // Функция для сортировки городов в администраторской панели
  function sortCitiesInAdminPanel() {
    // Ищем таблицы, которые еще не были отсортированы
    const tables = document.querySelectorAll('table:not([' + SORTED_ATTRIBUTE + '])');
    let found = false;
    
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
          
          // Сохраняем оригинальный порядок
          const originalOrder = rows.map(row => row.innerHTML);
          
          // Сортируем строки по первой или второй колонке (где обычно находится название города)
          const sortedRows = rows.sort((a, b) => {
            const aText = a.cells[1]?.textContent || a.cells[0]?.textContent || '';
            const bText = b.cells[1]?.textContent || b.cells[0]?.textContent || '';
            return aText.localeCompare(bText, 'ru');
          });
          
          // Проверяем, изменился ли порядок
          const newOrder = sortedRows.map(row => row.innerHTML);
          const hasChanged = originalOrder.some((html, index) => html !== newOrder[index]);
          
          if (hasChanged) {
            // Применяем отсортированный порядок только если порядок изменился
            sortedRows.forEach(row => {
              tbody.appendChild(row);
            });
            console.log('Таблица городов отсортирована по алфавиту');
          } else {
            console.log('Таблица городов уже отсортирована');
          }
        }
        
        // Помечаем таблицу как отсортированную
        table.setAttribute(SORTED_ATTRIBUTE, 'true');
        found = true;
      }
    });
    
    return found;
  }
  
  // Переменная для хранения состояния сортировки
  let sortingRunning = false;
  
  // Функция запуска сортировки с защитой от повторных вызовов
  function runSorting() {
    if (sortingRunning) return;
    
    sortingRunning = true;
    
    try {
      const dropdownSorted = sortCitiesInDropdown();
      
      // Проверяем, находимся ли мы в админке
      if (window.location.pathname.includes('/admin')) {
        const adminSorted = sortCitiesInAdminPanel();
        
        // Если ничего не отсортировано, останавливаем проверки
        if (!dropdownSorted && !adminSorted) {
          console.log('Сортировка завершена: все элементы отсортированы или не найдены');
        }
      }
    } finally {
      sortingRunning = false;
    }
  }
  
  // Запускаем начальную сортировку
  let initialCheckCount = 0;
  const initialCheckInterval = setInterval(() => {
    runSorting();
    initialCheckCount++;
    
    // Останавливаем интервал через 10 проверок
    if (initialCheckCount >= 10) {
      clearInterval(initialCheckInterval);
      console.log('Первичные проверки сортировки завершены');
    }
  }, 1000);
  
  // Наблюдаем за изменениями в DOM для повторной сортировки при динамической загрузке
  const observer = new MutationObserver((mutations) => {
    let shouldSort = false;
    
    for (const mutation of mutations) {
      if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
        // Проверяем, добавлены ли элементы, которые могут быть списками городов
        for (let i = 0; i < mutation.addedNodes.length; i++) {
          const node = mutation.addedNodes[i];
          if (node.nodeType === 1) { // ELEMENT_NODE
            if (
              node.tagName === 'SELECT' || 
              node.tagName === 'UL' || 
              node.tagName === 'TABLE' ||
              node.querySelector('select, ul, table')
            ) {
              shouldSort = true;
              break;
            }
          }
        }
        
        if (shouldSort) break;
      }
    }
    
    if (shouldSort) {
      // Запускаем сортировку с небольшой задержкой, чтобы дать React завершить рендеринг
      setTimeout(runSorting, 100);
    }
  });
  
  // Наблюдаем только за изменениями дочерних элементов
  observer.observe(document.body, { childList: true, subtree: true });
  
  console.log('Скрипт сортировки городов установлен');
})();
