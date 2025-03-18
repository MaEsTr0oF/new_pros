/**
 * Скрипт для исправления отображения структурированных данных
 */
(function() {
  function fixStructuredData() {
    // Удаляем отображаемые структурированные данные из документа
    const textNodes = [];
    const walk = document.createTreeWalker(
      document.body, 
      NodeFilter.SHOW_TEXT, 
      { acceptNode: node => node.nodeValue.includes('schema.org') ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_REJECT }
    );
    
    while (walk.nextNode()) {
      textNodes.push(walk.currentNode);
    }
    
    textNodes.forEach(node => {
      if (node.parentNode) {
        node.parentNode.removeChild(node);
      }
    });
    
    // Правильно добавляем структурированные данные в head
    if (!document.querySelector('script[type="application/ld+json"]')) {
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
      
      const script = document.createElement('script');
      script.type = 'application/ld+json';
      script.textContent = JSON.stringify(structuredData);
      document.head.appendChild(script);
      
      console.log('Структурированные данные правильно добавлены в head');
    }
  }
  
  // Запускаем исправление после загрузки страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fixStructuredData);
  } else {
    fixStructuredData();
  }
  
  // Запускаем также через небольшую задержку для надежности
  setTimeout(fixStructuredData, 1000);
})();
