#!/bin/bash
set -e

echo "🚀 Начинаем полную пересборку проекта (финальная версия)"

# Переходим в директорию проекта
cd /root/escort-project

# Останавливаем все контейнеры
echo "🛑 Останавливаем все контейнеры"
docker-compose down
docker rm -f escort-proxy escort-api-server || true

# Очищаем Docker-кэш
echo "🧹 Очищаем Docker-кэш"
docker system prune -af --volumes

# Пересобираем проект
echo "🏗️ Пересобираем проект"
docker-compose build --no-cache

# Запускаем проект
echo "✅ Запускаем проект"
docker-compose up -d

# Даем время для запуска сервисов
echo "⏳ Ожидаем запуск сервисов..."
sleep 15

# Создаем папку для скриптов
mkdir -p /usr/share/nginx/html/js

# Создаем скрипт для исправления структурированных данных
cat > /root/escort-project/fixed-schema.js << 'EOFINNER'
(function() {
  console.log('Скрипт исправления структурированных данных загружен');
  
  // Функция для удаления отображаемых структурированных данных
  function removeStructuredDataText() {
    // Ищем текстовые узлы с структурированными данными
    const walker = document.createTreeWalker(
      document.body,
      NodeFilter.SHOW_TEXT,
      null,
      false
    );
    
    const textNodes = [];
    let node;
    
    while (node = walker.nextNode()) {
      if (node.textContent && 
          node.textContent.trim().includes('"@context": "https://schema.org"') &&
          node.textContent.trim().includes('"@type": "WebSite"')) {
        textNodes.push(node);
      }
    }
    
    textNodes.forEach(node => {
      console.log('Удаляем структурированные данные с страницы');
      node.parentNode.removeChild(node);
    });
  }
  
  // Добавляем структурированные данные в head
  function addStructuredDataToHead() {
    // Проверяем, есть ли уже структурированные данные в head
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
  
  // Отключаем ServiceWorker
  function disableServiceWorker() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(registrations => {
        registrations.forEach(registration => {
          registration.unregister();
          console.log('ServiceWorker отключен');
        });
      });
    }
  }
  
  // Сортировка городов
  function sortCities() {
    // Находим все выпадающие списки
    const selects = document.querySelectorAll('select');
    
    selects.forEach(select => {
      // Пропускаем списки с менее чем 3 опциями
      if (select.options.length < 3) return;
      
      // Проверяем, что это список городов
      const options = Array.from(select.options);
      const isCitySelect = options.some(option => 
        option.text && (
          option.text.includes('Москва') || 
          option.text.includes('Санкт-Петербург') || 
          option.text.includes('Новосибирск')
        )
      );
      
      if (isCitySelect) {
        console.log('Найден список городов, сортируем');
        
        // Сохраняем выбранное значение
        const selectedValue = select.value;
        
        // Сортируем опции
        options.sort((a, b) => {
          // "Выберите город" всегда в начало
          if (a.value === '' || a.text.includes('Выберите')) return -1;
          if (b.value === '' || b.text.includes('Выберите')) return 1;
          
          // Остальные города по алфавиту
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
      }
    });
  }
  
  // Инициализируем функции
  function init() {
    console.log('Инициализация скрипта исправлений');
    
    // Запускаем функции
    removeStructuredDataText();
    addStructuredDataToHead();
    disableServiceWorker();
    sortCities();
    
    // Повторяем вызовы с интервалом для динамически загружаемого контента
    setTimeout(removeStructuredDataText, 1000);
    setTimeout(sortCities, 1000);
    setTimeout(removeStructuredDataText, 3000);
    setTimeout(sortCities, 3000);
  }
  
  // Запускаем при загрузке страницы
  document.addEventListener('DOMContentLoaded', init);
  
  // Наблюдаем за изменениями DOM
  const observer = new MutationObserver(() => {
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
docker cp /root/escort-project/fixed-schema.js escort-client:/usr/share/nginx/html/js/fixed-schema.js

# Обновляем index.html
echo "📄 Добавляем скрипт исправлений в index.html"
docker exec escort-client sh -c "sed -i '/<head>/a <script src=\"/js/fixed-schema.js\"></script>' /usr/share/nginx/html/index.html"

# Перезагружаем Nginx
docker exec escort-client nginx -s reload

echo "✅ Пересборка проекта завершена"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
