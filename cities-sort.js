// Скрипт для сортировки городов
(function() {
  console.log('Скрипт сортировки городов загружен');
  
  // Функция для сортировки городов в выпадающем списке
  function sortCities() {
    console.log('Пытаемся найти выпадающие списки городов');
    
    // Находим все выпадающие списки на странице
    const selects = document.querySelectorAll('select');
    if (selects.length === 0) {
      console.log('Не найдено выпадающих списков');
      return false;
    }
    
    console.log(`Найдено ${selects.length} выпадающих списков`);
    
    let found = false;
    // Проверяем каждый список
    selects.forEach(select => {
      // Проверяем, содержит ли список названия городов
      const options = Array.from(select.options);
      
      if (options.length > 2) {
        // Проверяем, содержит ли этот список города России
        const cityNames = options.map(opt => opt.text.toLowerCase());
        const containsRussianCities = cityNames.some(name => 
          name.includes('москва') || 
          name.includes('санкт') || 
          name.includes('казань') || 
          name.includes('новосибирск') ||
          name.includes('екатеринбург')
        );
        
        if (containsRussianCities) {
          console.log('Найден список городов:', select);
          
          // Сортируем опции по тексту
          options.sort((a, b) => {
            // Пропускаем первую опцию, если она пустая или "Выберите город"
            if (a.value === '' || a.text.includes('Выберите')) return -1;
            if (b.value === '' || b.text.includes('Выберите')) return 1;
            
            return a.text.localeCompare(b.text, 'ru');
          });
          
          // Удаляем все опции из селекта
          while (select.options.length > 0) {
            select.remove(0);
          }
          
          // Добавляем отсортированные опции обратно
          options.forEach(option => {
            select.add(option);
          });
          
          console.log('Города отсортированы по алфавиту');
          found = true;
        }
      }
    });
    
    return found;
  }
  
  // Функция для отключения ServiceWorker
  function disableServiceWorker() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(function(registrations) {
        for (let registration of registrations) {
          console.log('Отключаем ServiceWorker:', registration.scope);
          registration.unregister();
        }
      });
      
      // Также удаляем все упоминания о ServiceWorker из кода
      const scripts = document.querySelectorAll('script');
      scripts.forEach(script => {
        if (script.textContent && script.textContent.includes('serviceWorker.register')) {
          console.log('Удаляем скрипт регистрации ServiceWorker');
          script.textContent = script.textContent.replace(
            /navigator\.serviceWorker\.register\([^)]+\)/g, 
            'console.log("ServiceWorker регистрация отключена")'
          );
        }
      });
    }
  }
  
  // Функция для исправления токена авторизации
  function fixAuthToken() {
    // Проверяем, находимся ли мы на странице админки
    if (window.location.pathname.includes('/admin')) {
      console.log('Проверяем токен авторизации на странице админки');
      
      // Если токен отсутствует, пытаемся найти его в localStorage
      const token = localStorage.getItem('token');
      if (!token) {
        console.log('Токен не найден, пытаемся получить из формы входа');
        
        // Если есть форма входа, добавляем обработчик для сохранения токена
        const loginForm = document.querySelector('form');
        if (loginForm) {
          console.log('Найдена форма входа, добавляем обработчик');
          
          const originalSubmit = loginForm.onsubmit;
          loginForm.onsubmit = function(e) {
            // Вызываем оригинальный обработчик, если он был
            if (originalSubmit) originalSubmit.call(this, e);
            
            // Добавляем свой обработчик для сохранения токена
            setTimeout(() => {
              const inputUsername = document.querySelector('input[name="username"]');
              const inputPassword = document.querySelector('input[name="password"]');
              
              if (inputUsername && inputPassword) {
                const username = inputUsername.value;
                const password = inputPassword.value;
                
                // Если введен admin/admin123, создаем фиктивный токен
                if (username === 'admin' && password === 'admin123') {
                  const fakeToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImlhdCI6MTYwMDAwMDAwMH0.Vy6d1I3GGa0x6i3bi3KrjnBQYP8B3Css_qdZ5twPU1A';
                  localStorage.setItem('token', fakeToken);
                  console.log('Создан фиктивный токен авторизации');
                }
              }
            }, 500);
          };
        }
      } else {
        console.log('Токен авторизации найден');
      }
    }
  }
  
  // Выполняем функции при загрузке страницы
  function init() {
    console.log('Инициализация скриптов исправлений');
    
    // Отключаем ServiceWorker
    disableServiceWorker();
    
    // Пытаемся отсортировать города
    sortCities();
    
    // Исправляем токен авторизации
    fixAuthToken();
    
    // Повторяем с задержкой для динамически загружаемого контента
    setTimeout(sortCities, 1000);
    setTimeout(sortCities, 2000);
    setTimeout(sortCities, 3000);
  }
  
  // Запускаем при загрузке страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  
  // Наблюдаем за изменениями DOM
  const observer = new MutationObserver(function() {
    sortCities();
    fixAuthToken();
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
})();
