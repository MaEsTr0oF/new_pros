// Скрипт для сортировки анкет и городов
(function() {
  // Функция для сортировки анкет по полю order
  function sortProfiles() {
    // Находим контейнер с анкетами
    const profilesContainer = document.querySelector('.MuiGrid-container');
    if (!profilesContainer) return;
    
    // Получаем все карточки анкет
    const profileCards = Array.from(profilesContainer.children);
    if (profileCards.length <= 1) return;
    
    // Сортируем карточки по атрибуту data-order
    profileCards.sort((a, b) => {
      const orderA = parseInt(a.getAttribute('data-order') || '0', 10);
      const orderB = parseInt(b.getAttribute('data-order') || '0', 10);
      return orderA - orderB;
    });
    
    // Добавляем атрибут data-order, если его нет
    profileCards.forEach((card, index) => {
      if (!card.hasAttribute('data-order')) {
        card.setAttribute('data-order', index.toString());
      }
      // Перемещаем карточку на новую позицию
      profilesContainer.appendChild(card);
    });
    
    console.log('Анкеты отсортированы по порядку');
  }
  
  // Функция для сортировки городов по алфавиту
  function sortCities() {
    // Находим селект с городами
    const citySelect = document.querySelector('select[id*="city"]');
    if (!citySelect) return;
    
    // Получаем все опции
    const options = Array.from(citySelect.options);
    if (options.length <= 1) return;
    
    // Сортируем опции по тексту (название города)
    options.sort((a, b) => {
      return a.text.localeCompare(b.text, 'ru');
    });
    
    // Добавляем отсортированные опции обратно в селект
    options.forEach(option => {
      citySelect.appendChild(option);
    });
    
    console.log('Города отсортированы по алфавиту');
  }
  
  // Запускаем функции при загрузке страницы и при изменениях в DOM
  window.addEventListener('load', function() {
    // Запускаем сразу и с небольшой задержкой
    sortProfiles();
    sortCities();
    
    setTimeout(sortProfiles, 1000);
    setTimeout(sortCities, 1000);
    
    // Создаем MutationObserver для отслеживания изменений
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function() {
        sortProfiles();
        sortCities();
      });
    });
    
    // Начинаем наблюдение за изменениями в документе
    observer.observe(document.body, { 
      childList: true, 
      subtree: true 
    });
  });
})();
