// Простое одностраничное приложение для временной замены React
document.addEventListener('DOMContentLoaded', function() {
  const root = document.getElementById('root');
  const API_URL = 'https://eskortvsegorodarfreal.site/api';
  
  // Создаем навигацию
  const nav = document.createElement('nav');
  nav.innerHTML = `
    <div style="display: flex; justify-content: space-between; padding: 20px; background-color: #333; color: white;">
      <div style="font-size: 24px; font-weight: bold;">Эскорт услуги в России</div>
      <div>
        <a href="/" style="color: white; margin-right: 15px; text-decoration: none;">Главная</a>
        <a href="/admin" style="color: white; margin-right: 15px; text-decoration: none;">Админ</a>
        <a href="/admin/login" style="color: white; text-decoration: none;">Войти</a>
      </div>
    </div>
  `;
  
  // Определяем текущий путь
  const path = window.location.pathname;
  
  // Создаем содержимое
  const content = document.createElement('div');
  content.style.padding = '20px';
  
  // Функция для создания формы входа
  function createLoginForm() {
    return `
      <div style="max-width: 400px; margin: 0 auto; padding: 20px; border: 1px solid #ccc; border-radius: 5px;">
        <h2 style="text-align: center; margin-bottom: 20px;">Вход в админ-панель</h2>
        <div style="margin-bottom: 15px;">
          <label style="display: block; margin-bottom: 5px;">Имя пользователя:</label>
          <input type="text" id="username" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
        </div>
        <div style="margin-bottom: 20px;">
          <label style="display: block; margin-bottom: 5px;">Пароль:</label>
          <input type="password" id="password" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
        </div>
        <button id="loginBtn" style="width: 100%; padding: 10px; background-color: #4CAF50; color: white; border: none; border-radius: 4px; cursor: pointer;">Войти</button>
        <div id="loginError" style="color: red; margin-top: 10px; text-align: center;"></div>
      </div>
    `;
  }
  
  // Функция для создания админ-панели
  function createAdminPanel() {
    return `
      <div>
        <h1 style="margin-bottom: 20px;">Админ-панель</h1>
        <div style="display: flex; margin-bottom: 20px;">
          <div style="width: 250px; background-color: #f1f1f1; padding: 20px;">
            <h3 style="margin-bottom: 15px;">Меню</h3>
            <ul style="list-style: none; padding: 0;">
              <li style="margin-bottom: 10px;"><a href="/admin/dashboard" style="text-decoration: none; color: #333;">Панель управления</a></li>
              <li style="margin-bottom: 10px;"><a href="/admin/profiles" style="text-decoration: none; color: #333;">Анкеты</a></li>
              <li style="margin-bottom: 10px;"><a href="/admin/cities" style="text-decoration: none; color: #333;">Города</a></li>
              <li style="margin-bottom: 10px;"><a href="/admin/settings" style="text-decoration: none; color: #333;">Настройки</a></li>
              <li><a href="#" id="logoutBtn" style="text-decoration: none; color: #333;">Выйти</a></li>
            </ul>
          </div>
          <div style="flex-grow: 1; padding: 20px;">
            <h2>Управление анкетами</h2>
            <p>Для восстановления полной работоспособности сайта, необходимо перезапустить контейнер client.</p>
            <button id="refreshBtn" style="padding: 10px; background-color: #4CAF50; color: white; border: none; border-radius: 4px; cursor: pointer; margin-top: 15px;">Обновить страницу</button>
          </div>
        </div>
      </div>
    `;
  }
  
  // Заполняем содержимое в зависимости от пути
  if (path.startsWith('/admin/login')) {
    content.innerHTML = createLoginForm();
    
    // Добавляем функционал кнопке входа
    setTimeout(() => {
      const loginBtn = document.getElementById('loginBtn');
      if (loginBtn) {
        loginBtn.addEventListener('click', async () => {
          const username = document.getElementById('username').value;
          const password = document.getElementById('password').value;
          const errorDiv = document.getElementById('loginError');
          
          if (!username || !password) {
            errorDiv.textContent = 'Введите имя пользователя и пароль';
            return;
          }
          
          try {
            const response = await fetch(`${API_URL}/auth/login`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ username, password })
            });
            
            const data = await response.json();
            
            if (response.ok && data.token) {
              localStorage.setItem('token', data.token);
              window.location.href = '/admin/dashboard';
            } else {
              errorDiv.textContent = data.message || 'Ошибка входа';
            }
          } catch (error) {
            errorDiv.textContent = 'Ошибка соединения с сервером';
            console.error('Login error:', error);
          }
        });
      }
    }, 100);
  } else if (path.startsWith('/admin')) {
    const token = localStorage.getItem('token');
    
    if (!token && !path.includes('login')) {
      window.location.href = '/admin/login';
      return;
    }
    
    content.innerHTML = createAdminPanel();
    
    // Добавляем функционал кнопке выхода
    setTimeout(() => {
      const logoutBtn = document.getElementById('logoutBtn');
      if (logoutBtn) {
        logoutBtn.addEventListener('click', () => {
          localStorage.removeItem('token');
          window.location.href = '/admin/login';
        });
      }
      
      const refreshBtn = document.getElementById('refreshBtn');
      if (refreshBtn) {
        refreshBtn.addEventListener('click', () => {
          window.location.reload();
        });
      }
    }, 100);
  } else {
    // Главная страница
    content.innerHTML = `
      <div style="text-align: center; padding: 50px 20px;">
        <h1 style="margin-bottom: 20px;">Проститутки России | VIP Эскорт услуги</h1>
        <p style="max-width: 800px; margin: 0 auto; margin-bottom: 30px;">
          На нашем сайте представлены элитные проститутки и индивидуалки из 50 городов России. 
          Все анкеты с проверенными фото девушек, предоставляющих VIP эскорт услуги. 
          Выберите город и найдите подходящую девушку для приятного времяпрепровождения.
        </p>
        <p>
          <button id="adminBtn" style="padding: 10px 20px; background-color: #4CAF50; color: white; border: none; border-radius: 4px; cursor: pointer;">Перейти в админ-панель</button>
        </p>
      </div>
    `;
    
    // Добавляем функционал кнопке перехода в админ-панель
    setTimeout(() => {
      const adminBtn = document.getElementById('adminBtn');
      if (adminBtn) {
        adminBtn.addEventListener('click', () => {
          window.location.href = '/admin';
        });
      }
    }, 100);
  }
  
  // Добавляем элементы на страницу
  root.appendChild(nav);
  root.appendChild(content);
});

// Функция для запроса списка городов и отображения их
async function fetchCities() {
  try {
    const response = await fetch('https://eskortvsegorodarfreal.site/api/cities');
    const cities = await response.json();
    console.log('Доступные города:', cities);
  } catch (error) {
    console.error('Ошибка при загрузке городов:', error);
  }
}

// Вызываем функцию загрузки городов
fetchCities();
