(function() {
  // Создаем структурированные данные для сайта (SEO)
  function createStructuredData() {
    var websiteData = {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "VIP Эскорт Услуги",
      "url": window.location.origin,
      "potentialAction": {
        "@type": "SearchAction",
        "target": window.location.origin + "/search?q={search_term_string}",
        "query-input": "required name=search_term_string"
      }
    };
    
    var organizationData = {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "VIP Эскорт Услуги",
      "url": window.location.origin,
      "logo": window.location.origin + "/logo.png"
    };
    
    function addJsonLd(data) {
      var script = document.createElement('script');
      script.type = 'application/ld+json';
      script.text = JSON.stringify(data);
      document.head.appendChild(script);
    }
    
    addJsonLd(websiteData);
    addJsonLd(organizationData);
    
    console.log('Структурированные данные добавлены');
  }
  
  // Запускаем после загрузки страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', createStructuredData);
  } else {
    createStructuredData();
  }
})();
