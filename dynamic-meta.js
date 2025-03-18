// Скрипт для обновления метаданных на всех страницах
(function() {
  // Функция для установки всех метаданных сайта
  function setCorrectMetadata() {
    // Устанавливаем правильный title
    document.title = "Эскорт услуги в России | Шлюхи, проститутки, куртизанки";
    
    // Обновляем все мета-теги description
    var metaDescription = document.querySelector('meta[name="description"]');
    if (metaDescription) {
      metaDescription.setAttribute('content', 'Эскорт услуги в России. Шлюхи, проститутки, куртизанки, женщины древнейшей профессии. VIP индивидуалки и девушки по вызову.');
    } else {
      metaDescription = document.createElement('meta');
      metaDescription.name = 'description';
      metaDescription.content = 'Эскорт услуги в России. Шлюхи, проститутки, куртизанки, женщины древнейшей профессии. VIP индивидуалки и девушки по вызову.';
      document.head.appendChild(metaDescription);
    }
    
    // Обновляем Open Graph теги
    var ogTags = {
      'og:title': 'Эскорт услуги в России | Шлюхи, проститутки, куртизанки',
      'og:description': 'Эскорт услуги в России. Шлюхи, проститутки, куртизанки, женщины древнейшей профессии. VIP индивидуалки и девушки по вызову.',
      'og:type': 'website',
      'og:url': window.location.href,
      'og:site_name': 'Эскорт услуги в России'
    };
    
    // Устанавливаем или обновляем OG теги
    Object.keys(ogTags).forEach(function(key) {
      var ogTag = document.querySelector('meta[property="' + key + '"]');
      if (ogTag) {
        ogTag.setAttribute('content', ogTags[key]);
      } else {
        ogTag = document.createElement('meta');
        ogTag.setAttribute('property', key);
        ogTag.setAttribute('content', ogTags[key]);
        document.head.appendChild(ogTag);
      }
    });
    
    console.log('Метаданные обновлены для всех страниц сайта');
  }
  
  // Запускаем обновление метаданных
  setCorrectMetadata();
  
  // Также отслеживаем изменение URL для SPA
  var lastUrl = window.location.href;
  new MutationObserver(function() {
    if (lastUrl !== window.location.href) {
      lastUrl = window.location.href;
      setTimeout(setCorrectMetadata, 100);
    }
  }).observe(document, {subtree: true, childList: true});
})();
