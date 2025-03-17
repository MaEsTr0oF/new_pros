document.addEventListener('DOMContentLoaded', function() {
  // Создаем стиль для grid сетки
  const style = document.createElement('style');
  
  style.textContent = `
    /* Контейнер для кнопок фильтров */
    .MuiBox-root:has(button) {
      display: grid !important;
      grid-template-columns: repeat(auto-fill, minmax(95px, 1fr)) !important;
      gap: 8px !important;
      margin-bottom: 16px !important;
    }
    
    /* Стили для маленьких экранов */
    @media (max-width: 480px) {
      .MuiBox-root:has(button) {
        grid-template-columns: repeat(auto-fill, minmax(70px, 1fr)) !important;
        gap: 6px !important;
      }
      
      .MuiBox-root:has(button) .MuiButton-root {
        padding: 6px 8px !important;
        font-size: 12px !important;
        min-width: unset !important;
      }
    }
    
    /* Стили для очень маленьких экранов */
    @media (max-width: 360px) {
      .MuiBox-root:has(button) {
        grid-template-columns: repeat(auto-fill, minmax(60px, 1fr)) !important;
        gap: 4px !important;
      }
      
      .MuiBox-root:has(button) .MuiButton-root {
        padding: 4px 6px !important;
        font-size: 11px !important;
      }
    }
  `;
  
  document.head.appendChild(style);
});
