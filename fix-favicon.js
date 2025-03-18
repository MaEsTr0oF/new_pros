// Исправление проблемы с favicon
(function() {
  // Добавляем favicon если его нет
  if (!document.querySelector('link[rel="icon"]')) {
    const favicon = document.createElement('link');
    favicon.rel = 'icon';
    favicon.href = '/favicon.ico';
    document.head.appendChild(favicon);
  }
  
  // Добавляем обработчик ошибок для предотвращения ошибок загрузки favicon
  window.addEventListener('error', function(e) {
    if (e.target.tagName === 'LINK' && e.target.rel === 'icon') {
      e.preventDefault();
      e.stopPropagation();
      return false;
    }
  }, true);
})();
