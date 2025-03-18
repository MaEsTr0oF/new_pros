// Скрипт для диагностики и исправления ошибок загрузки
(function() {
  // Логируем все ошибки
  window.addEventListener('error', function(e) {
    console.log('Перехваченная ошибка:', e.message, e.filename);
    return false;
  }, true);
  
  // Если страница загружается с ошибкой, попробуем перезагрузить через 5 секунд
  if (document.title.indexOf('Error') !== -1) {
    console.log('Обнаружена страница ошибки, перезагрузка через 5 секунд...');
    setTimeout(function() {
      window.location.reload();
    }, 5000);
  }
})();
