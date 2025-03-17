/**
 * Скрипт для динамического формирования Schema.org разметки
 * в зависимости от текущей страницы
 */
(function() {
  // Получаем текущий путь
  const path = window.location.pathname;
  
  // Базовый URL сайта
  const baseUrl = 'https://eskortvsegorodarfreal.site';
  
  // Информация о сайте
  const siteSchema = {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "Эскорт услуги в России",
    "url": baseUrl,
    "potentialAction": {
      "@type": "SearchAction",
      "target": baseUrl + "/?search={search_term_string}",
      "query-input": "required name=search_term_string"
    }
  };
  
  // Функция для создания BreadcrumbList schema
  function createBreadcrumbSchema() {
    const parts = path.split('/').filter(p => p);
    if (parts.length === 0) return null;
    
    const items = [{
      "@type": "ListItem",
      "position": 1,
      "name": "Главная",
      "item": baseUrl
    }];
    
    let currentPath = '';
    parts.forEach((part, index) => {
      currentPath += '/' + part;
      items.push({
        "@type": "ListItem",
        "position": index + 2,
        "name": part.charAt(0).toUpperCase() + part.slice(1),
        "item": baseUrl + currentPath
      });
    });
    
    return {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items
    };
  }
  
  // Подготавливаем данные для вставки
  const schemaList = [siteSchema];
  
  // Если не главная страница, добавляем хлебные крошки
  if (path !== '/') {
    const breadcrumbs = createBreadcrumbSchema();
    if (breadcrumbs) {
      schemaList.push(breadcrumbs);
    }
  }
  
  // Вставляем данные на страницу
  schemaList.forEach(schema => {
    const script = document.createElement('script');
    script.type = 'application/ld+json';
    script.textContent = JSON.stringify(schema);
    document.head.appendChild(script);
  });
  
  console.log('Structured data generated and injected');
})(); 