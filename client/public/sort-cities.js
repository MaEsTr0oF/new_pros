(function() {
  // Функция для сортировки городов в алфавитном порядке
  function sortCities() {
    // Находим селект с городами
    var citySelect = document.querySelector('select#city-select, select[name="city"]');
    if (!citySelect) {
      console.log('Селект с городами не найден');
      return;
    }
    
    // Получаем все опции
    var options = Array.from(citySelect.options);
    
    // Сортируем в алфавитном порядке (с учетом кириллицы)
    options.sort(function(a, b) {
      return a.text.localeCompare(b.text, 'ru');
    });
    
    // Очищаем селект
    citySelect.innerHTML = '';
    
    // Добавляем отсортированные опции
    options.forEach(function(option) {
      citySelect.appendChild(option);
    });
    
    console.log('Города отсортированы по алфавиту');
  }
  
  // Запускаем после загрузки страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', sortCities);
  } else {
    sortCities();
  }
})();
