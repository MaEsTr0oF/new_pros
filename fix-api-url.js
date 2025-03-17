document.addEventListener('DOMContentLoaded', function() {
  // Перезаписываем API_URL
  window.API_URL = 'http://eskortvsegorodarfreal.site/api';
  console.log('API_URL принудительно изменен на:', window.API_URL);
  
  // Также меняем axios базовый URL для всех запросов
  if (window.axios) {
    window.axios.defaults.baseURL = 'http://eskortvsegorodarfreal.site/api';
    console.log('Axios baseURL изменен на:', window.axios.defaults.baseURL);
  }
});
