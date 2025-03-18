// Скрипт для добавления кнопок перемещения в админке
(function() {
  // Функция для получения токена авторизации
  function getAuthToken() {
    return localStorage.getItem('token');
  }

  // Функция для перемещения профиля вверх
  async function moveProfileUp(id) {
    try {
      const token = getAuthToken();
      
      const response = await fetch(`/api/admin/profiles/${id}/moveUp`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (response.ok) {
        console.log(`Профиль ${id} перемещен вверх`);
        window.location.reload();
      } else {
        console.error('Ошибка при перемещении профиля вверх', await response.text());
        alert('Ошибка при перемещении профиля вверх');
      }
    } catch (error) {
      console.error('Ошибка при вызове API:', error);
      alert('Ошибка при вызове API');
    }
  }

  // Функция для перемещения профиля вниз
  async function moveProfileDown(id) {
    try {
      const token = getAuthToken();
      
      const response = await fetch(`/api/admin/profiles/${id}/moveDown`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (response.ok) {
        console.log(`Профиль ${id} перемещен вниз`);
        window.location.reload();
      } else {
        console.error('Ошибка при перемещении профиля вниз', await response.text());
        alert('Ошибка при перемещении профиля вниз');
      }
    } catch (error) {
      console.error('Ошибка при вызове API:', error);
      alert('Ошибка при вызове API');
    }
  }

  // Функция для создания кнопок управления порядком
  function createOrderButtons() {
    // Проверяем, что мы находимся в административной панели
    if (!window.location.pathname.includes('/admin')) {
      return;
    }
    
    console.log('Добавляем кнопки управления порядком анкет в админ-панели');
    
    // Находим таблицу с анкетами
    const profileRows = document.querySelectorAll('tr');
    
    // Проходим по всем строкам таблицы
    profileRows.forEach(row => {
      // Пропускаем заголовок таблицы
      if (row.querySelector('th')) {
        return;
      }
      
      // Получаем ID профиля
      const idCell = row.querySelector('td:first-child');
      if (!idCell) {
        return;
      }
      
      const profileId = idCell.textContent.trim();
      if (!profileId || isNaN(Number(profileId))) {
        return;
      }
      
      // Находим ячейку с действиями
      const actionCell = row.querySelector('td:last-child');
      if (!actionCell) {
        return;
      }
      
      // Проверяем, есть ли уже кнопки управления порядком
      if (actionCell.querySelector('.order-buttons')) {
        return;
      }
      
      // Создаем контейнер для кнопок
      const buttonsContainer = document.createElement('div');
      buttonsContainer.className = 'order-buttons';
      buttonsContainer.style.display = 'inline-flex';
      buttonsContainer.style.marginLeft = '8px';
      
      // Кнопка вверх
      const upButton = document.createElement('button');
      upButton.innerHTML = '⬆️';
      upButton.title = 'Переместить вверх';
      upButton.style.margin = '0 2px';
      upButton.style.padding = '0 4px';
      upButton.style.cursor = 'pointer';
      upButton.onclick = (e) => {
        e.preventDefault();
        e.stopPropagation();
        moveProfileUp(profileId);
      };
      
      // Кнопка вниз
      const downButton = document.createElement('button');
      downButton.innerHTML = '⬇️';
      downButton.title = 'Переместить вниз';
      downButton.style.margin = '0 2px';
      downButton.style.padding = '0 4px';
      downButton.style.cursor = 'pointer';
      downButton.onclick = (e) => {
        e.preventDefault();
        e.stopPropagation();
        moveProfileDown(profileId);
      };
      
      // Добавляем кнопки в контейнер
      buttonsContainer.appendChild(upButton);
      buttonsContainer.appendChild(downButton);
      
      // Добавляем контейнер с кнопками в ячейку действий
      actionCell.appendChild(buttonsContainer);
    });
  }

  // Запускаем создание кнопок при загрузке страницы
  window.addEventListener('load', function() {
    // Запускаем сразу и с небольшой задержкой для динамически загружаемого контента
    createOrderButtons();
    
    // Повторяем несколько раз с задержкой, чтобы поймать момент загрузки контента
    setTimeout(createOrderButtons, 1000);
    setTimeout(createOrderButtons, 2000);
    setTimeout(createOrderButtons, 3000);
    
    // Добавляем кнопки при переходе между страницами через history API
    window.addEventListener('popstate', function() {
      setTimeout(createOrderButtons, 500);
    });
    
    // Наблюдаем за изменениями в DOM, чтобы добавить кнопки к новым элементам
    const observer = new MutationObserver(function(mutations) {
      createOrderButtons();
    });
    
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  });

  // Отключаем ServiceWorker, который вызывает ошибки
  function unregisterServiceWorker() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(function(registrations) {
        for (let registration of registrations) {
          registration.unregister().then(function(success) {
            console.log('ServiceWorker успешно удален:', success);
          });
        }
      });
    }
  }
  
  // Отключаем ServiceWorker при загрузке страницы
  unregisterServiceWorker();
})();
