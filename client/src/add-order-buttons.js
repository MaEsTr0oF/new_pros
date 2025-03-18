// Скрипт для добавления кнопок управления порядком анкет
(function() {
  // Функция для перемещения анкеты вверх
  async function moveProfileUp(id) {
    try {
      const response = await fetch(`/api/admin/profiles/${id}/moveUp`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (response.ok) {
        // Перезагружаем страницу после успешного перемещения
        window.location.reload();
      } else {
        console.error('Ошибка при перемещении анкеты вверх');
        alert('Ошибка при перемещении анкеты вверх');
      }
    } catch (error) {
      console.error('Ошибка при отправке запроса:', error);
      alert('Ошибка при отправке запроса');
    }
  }

  // Функция для перемещения анкеты вниз
  async function moveProfileDown(id) {
    try {
      const response = await fetch(`/api/admin/profiles/${id}/moveDown`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (response.ok) {
        // Перезагружаем страницу после успешного перемещения
        window.location.reload();
      } else {
        console.error('Ошибка при перемещении анкеты вниз');
        alert('Ошибка при перемещении анкеты вниз');
      }
    } catch (error) {
      console.error('Ошибка при отправке запроса:', error);
      alert('Ошибка при отправке запроса');
    }
  }

  // Функция для добавления кнопок к анкетам
  function addOrderButtons() {
    // Найдем все карточки анкет на странице
    const profileCards = document.querySelectorAll('.MuiCard-root');
    
    profileCards.forEach(card => {
      // Находим ID анкеты
      const profileIdMatch = card.querySelector('a[href^="/admin/profiles/edit/"]');
      if (!profileIdMatch) return;
      
      const href = profileIdMatch.getAttribute('href');
      const profileId = href.split('/').pop();
      
      // Если уже есть кнопки перемещения, не добавляем их снова
      if (card.querySelector('.order-buttons-container')) return;
      
      if (!profileId) return;
      
      // Находим блок с действиями (CardActions)
      const actionsBlock = card.querySelector('.MuiCardActions-root');
      if (!actionsBlock) return;
      
      // Создаем кнопки для перемещения вверх/вниз
      const buttonsContainer = document.createElement('div');
      buttonsContainer.className = 'order-buttons-container';
      buttonsContainer.style.marginLeft = 'auto';
      
      // Кнопка "Вверх"
      const upButton = document.createElement('button');
      upButton.className = 'MuiButtonBase-root MuiIconButton-root MuiIconButton-sizeSmall';
      upButton.innerHTML = '<svg class="MuiSvgIcon-root MuiSvgIcon-fontSizeSmall" focusable="false" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 12l1.41 1.41L11 7.83V20h2V7.83l5.58 5.59L20 12l-8-8-8 8z"></path></svg>';
      upButton.title = 'Переместить вверх';
      upButton.onclick = (e) => {
        e.preventDefault();
        e.stopPropagation();
        moveProfileUp(profileId);
      };
      
      // Кнопка "Вниз"
      const downButton = document.createElement('button');
      downButton.className = 'MuiButtonBase-root MuiIconButton-root MuiIconButton-sizeSmall';
      downButton.innerHTML = '<svg class="MuiSvgIcon-root MuiSvgIcon-fontSizeSmall" focusable="false" viewBox="0 0 24 24" aria-hidden="true"><path d="M20 12l-1.41-1.41L13 16.17V4h-2v12.17l-5.58-5.59L4 12l8 8 8-8z"></path></svg>';
      downButton.title = 'Переместить вниз';
      downButton.onclick = (e) => {
        e.preventDefault();
        e.stopPropagation();
        moveProfileDown(profileId);
      };
      
      buttonsContainer.appendChild(upButton);
      buttonsContainer.appendChild(downButton);
      
      // Добавляем кнопки в блок действий
      actionsBlock.appendChild(buttonsContainer);
    });
  }

  // Запускаем функцию при загрузке страницы
  window.addEventListener('load', function() {
    // Проверяем, находимся ли мы в админке
    if (window.location.pathname.startsWith('/admin')) {
      console.log('Добавляем кнопки управления порядком анкет');
      
      // Добавляем кнопки сразу и через небольшую задержку для динамически загружаемого контента
      addOrderButtons();
      setTimeout(addOrderButtons, 1000);
      setTimeout(addOrderButtons, 2000);
    }
  });
})();
