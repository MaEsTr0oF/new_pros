// Скрипт для добавления кнопок сортировки анкет
(function() {
  console.log('Скрипт сортировки анкет загружен');
  
  // Функция для перемещения анкеты вверх/вниз
  function moveProfile(id, direction) {
    console.log(`Перемещаем профиль ${id} ${direction === 'up' ? 'вверх' : 'вниз'}`);
    
    const token = localStorage.getItem('token');
    if (!token) {
      console.error('Нет токена авторизации');
      return;
    }
    
    // Делаем запрос к API
    fetch(`http://77.73.235.201:3000/api/admin/profiles/${id}/move${direction === 'up' ? 'Up' : 'Down'}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
    .then(response => {
      if (response.ok) {
        console.log(`Профиль ${id} успешно перемещен ${direction === 'up' ? 'вверх' : 'вниз'}`);
        window.location.reload();
      } else {
        console.error(`Ошибка при перемещении профиля: ${response.status}`);
      }
    })
    .catch(error => {
      console.error('Ошибка при выполнении запроса:', error);
    });
  }
  
  // Функция для добавления кнопок управления порядком
  function addSortButtons() {
    // Проверяем, что мы на странице админки
    if (!window.location.pathname.includes('/admin')) {
      return;
    }
    
    console.log('Добавляем кнопки сортировки на страницу админки');
    
    // Ищем все строки таблицы
    const rows = document.querySelectorAll('tr');
    if (rows.length === 0) {
      console.log('Строки таблицы не найдены');
      return;
    }
    
    console.log(`Найдено ${rows.length} строк таблицы`);
    
    rows.forEach(row => {
      // Пропускаем заголовок таблицы
      if (row.querySelector('th')) {
        return;
      }
      
      // Получаем ID профиля
      const firstCell = row.querySelector('td:first-child');
      if (!firstCell) {
        console.log('Не найдена первая ячейка с ID');
        return;
      }
      
      const profileId = firstCell.textContent.trim();
      
      // Получаем ячейку действий (последнюю)
      const lastCell = row.querySelector('td:last-child');
      if (!lastCell) {
        console.log('Не найдена ячейка действий');
        return;
      }
      
      // Проверяем, добавлены ли уже кнопки
      if (lastCell.querySelector('.sort-buttons')) {
        return;
      }
      
      // Создаем контейнер для кнопок
      const buttonsContainer = document.createElement('div');
      buttonsContainer.className = 'sort-buttons';
      buttonsContainer.style.display = 'inline-block';
      buttonsContainer.style.marginLeft = '8px';
      
      // Кнопка "Вверх"
      const upButton = document.createElement('button');
      upButton.innerHTML = '⬆️';
      upButton.style.margin = '0 2px';
      upButton.style.cursor = 'pointer';
      upButton.title = 'Переместить вверх';
      upButton.onclick = (e) => {
        e.preventDefault();
        e.stopPropagation();
        moveProfile(profileId, 'up');
      };
      
      // Кнопка "Вниз"
      const downButton = document.createElement('button');
      downButton.innerHTML = '⬇️';
      downButton.style.margin = '0 2px';
      downButton.style.cursor = 'pointer';
      downButton.title = 'Переместить вниз';
      downButton.onclick = (e) => {
        e.preventDefault();
        e.stopPropagation();
        moveProfile(profileId, 'down');
      };
      
      // Добавляем кнопки в контейнер
      buttonsContainer.appendChild(upButton);
      buttonsContainer.appendChild(downButton);
      
      // Добавляем контейнер в ячейку действий
      lastCell.appendChild(buttonsContainer);
      
      console.log(`Добавлены кнопки сортировки для профиля ${profileId}`);
    });
  }
  
  // Сортировка городов
  function sortCities() {
    // Находим выпадающий список с городами
    const citySelect = document.querySelector('select[id*="city"]');
    if (!citySelect) {
      console.log('Выпадающий список городов не найден');
      return;
    }
    
    console.log('Найден выпадающий список городов');
    
    // Получаем все опции
    const options = Array.from(citySelect.options);
    
    // Сортируем опции по тексту
    options.sort((a, b) => {
      if (!a.text || !b.text) return 0;
      return a.text.localeCompare(b.text, 'ru');
    });
    
    // Удаляем все опции из селекта
    while (citySelect.options.length > 0) {
      citySelect.remove(0);
    }
    
    // Добавляем отсортированные опции обратно
    options.forEach(option => {
      citySelect.add(option);
    });
    
    console.log('Города отсортированы по алфавиту');
  }
  
  // Отключаем Service Worker
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
  window.addEventListener('load', function() {
    console.log('Страница загружена, запускаем скрипты');
    
    // Отключаем Service Worker
    disableServiceWorker();
    
    // Добавляем кнопки сортировки
    addSortButtons();
    
    // Сортируем города
    sortCities();
    
    // Повторяем с задержкой для динамически загружаемого контента
    setTimeout(addSortButtons, 1000);
    setTimeout(sortCities, 1000);
    setTimeout(addSortButtons, 2000);
    setTimeout(sortCities, 2000);
    
    // Наблюдаем за изменениями DOM
    const observer = new MutationObserver(function(mutations) {
      addSortButtons();
      sortCities();
    });
    
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  });
})();
