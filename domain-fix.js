// Скрипт определения текущего хоста
(function() {
  // Определяем, откуда загружена страница
  var currentHost = window.location.hostname;
  var currentProtocol = window.location.protocol;
  console.log('Страница загружена с: ' + currentProtocol + '//' + currentHost);
  
  // Если загружено с домена, используем его для API
  if (currentHost === 'eskortvsegorodarfreal.site') {
    window.API_URL = currentProtocol + '//' + currentHost + '/api';
    console.log('API_URL установлен на: ' + window.API_URL);
    
    // Перехватываем axios, если он инициализирован
    if (window.axios) {
      window.axios.defaults.baseURL = window.API_URL;
      console.log('axios baseURL изменен на: ' + window.API_URL);
    }
    
    // Ждем инициализации axios
    var checkAxios = setInterval(function() {
      if (window.axios) {
        window.axios.defaults.baseURL = window.API_URL;
        console.log('axios baseURL изменен на: ' + window.API_URL);
        clearInterval(checkAxios);
      }
    }, 100);
  }
})();
