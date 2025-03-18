#!/bin/bash
set -e

echo "🚀 Запускаем пересборку клиента"

# Переходим в директорию проекта
cd /root/escort-project

# Останавливаем контейнер клиента
echo "🛑 Останавливаем контейнер клиента"
docker-compose stop client
docker-compose rm -f client

# Пересобираем только клиент
echo "🏗️ Пересобираем клиент"
docker-compose build --no-cache client

# Запускаем клиент
echo "✅ Запускаем клиент"
docker-compose up -d client

# Даем время для запуска сервиса
echo "⏳ Ожидаем запуск клиента..."
sleep 10

# Создаем директорию для js в контейнере
mkdir -p /usr/share/nginx/html/js

# Создаем скрипт для исправления структурированных данных
cat > /root/escort-project/fix-display.js << 'EOFINNER'
(function() {
  console.log('Скрипт исправления структурированных данных запущен');
  
  // Функция для удаления отображаемых структурированных данных
  function removeStructuredDataText() {
    // Находим и удаляем структурированные данные, которые отображаются как текст
    const textNodes = [];
    const walker = document.createTreeWalker(
      document.body,
      NodeFilter.SHOW_TEXT,
      null,
      false
    );
    
    let node;
    while (node = walker.nextNode()) {
      if (node.textContent && 
          node.textContent.includes('@context') && 
          node.textContent.includes('schema.org')) {
        textNodes.push(node);
      }
    }
    
    if (textNodes.length > 0) {
      console.log(`Найдено ${textNodes.length} узлов со структурированными данными`);
      textNodes.forEach(node => {
        node.parentNode.removeChild(node);
      });
      console.log('Неправильно отображаемые структурированные данные удалены');
    }
  }
  
  // Функция для сортировки городов
  function sortCities() {
    const selects = document.querySelectorAll('select');
    
    selects.forEach(select => {
      // Проверяем, что это выпадающий список городов
      if (select.options.length > 2) {
        const options = Array.from(select.options);
        const cityNames = options.map(opt => opt.text.toLowerCase());
        
        if (cityNames.some(name => 
             name.includes('москва') || 
             name.includes('санкт') || 
             name.includes('екатер'))) {
          
          console.log('Найден выпадающий список городов, сортируем');
          
          // Сохраняем выбранное значение
          const selectedValue = select.value;
          
          // Сортируем опции
          options.sort((a, b) => {
            if (a.value === '' || a.text.includes('Выберите')) return -1;
            if (b.value === '' || b.text.includes('Выберите')) return 1;
            return a.text.localeCompare(b.text, 'ru');
          });
          
          // Удаляем все опции
          while (select.options.length > 0) {
            select.remove(0);
          }
          
          // Добавляем отсортированные опции
          options.forEach(option => select.add(option));
          
          // Восстанавливаем выбранное значение
          if (selectedValue) {
            select.value = selectedValue;
          }
          
          console.log('Города отсортированы по алфавиту');
        }
      }
    });
  }
  
  // Запускаем функции при загрузке страницы
  function init() {
    removeStructuredDataText();
    sortCities();
    
    // Повторяем с задержкой для обработки динамически загружаемого контента
    setTimeout(removeStructuredDataText, 1000);
    setTimeout(sortCities, 1000);
    setTimeout(removeStructuredDataText, 3000);
    setTimeout(sortCities, 3000);
  }
  
  // Запускаем инициализацию
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
EOFINNER

# Копируем скрипт в контейнер
docker cp /root/escort-project/fix-display.js escort-client:/usr/share/nginx/html/js/fix-display.js

# Добавляем скрипт в index.html
docker exec escort-client sh -c "grep -q 'fix-display.js' /usr/share/nginx/html/index.html || sed -i '/<head>/a <script src=\"/js/fix-display.js\"></script>' /usr/share/nginx/html/index.html"

# Перезагружаем Nginx
docker exec escort-client nginx -s reload

echo "✅ Пересборка клиента завершена"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
