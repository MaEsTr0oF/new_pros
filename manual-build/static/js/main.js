document.addEventListener('DOMContentLoaded', function() {
  // Показываем индикатор загрузки
  const loadingIndicator = document.getElementById('loading-indicator');
  loadingIndicator.style.display = 'flex';

  // Константы приложения
  const API_URL = 'https://eskortvsegorodarfreal.site/api';
  
  // Функция для создания элементов DOM
  function createElement(tag, props = {}, children = []) {
    const element = document.createElement(tag);
    
    Object.entries(props).forEach(([key, value]) => {
      if (key === 'className') {
        element.className = value;
      } else if (key === 'style' && typeof value === 'object') {
        Object.entries(value).forEach(([cssProp, cssValue]) => {
          element.style[cssProp] = cssValue;
        });
      } else if (key.startsWith('on') && typeof value === 'function') {
        const eventName = key.substring(2).toLowerCase();
        element.addEventListener(eventName, value);
      } else {
        element[key] = value;
      }
    });
    
    children.forEach(child => {
      if (typeof child === 'string') {
        element.appendChild(document.createTextNode(child));
      } else if (child instanceof Node) {
        element.appendChild(child);
      }
    });
    
    return element;
  }

  // Функция для выполнения API запросов
  async function fetchApi(endpoint, options = {}) {
    try {
      const response = await fetch(`${API_URL}/${endpoint}`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...options.headers
        }
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      console.error(`Error fetching ${endpoint}:`, error);
      return null;
    }
  }

  // Создание основного макета приложения
  function createAppLayout() {
    const root = document.getElementById('root');
    if (!root) return;
    
    // Создаем хедер
    const header = createElement('header', { className: 'header' }, [
      createElement('div', { className: 'container header-content' }, [
        createElement('a', { href: '/', className: 'logo' }, ['VIP Эскорт']),
        createElement('nav', { className: 'nav' }, [
          createElement('a', { href: '/', className: 'nav-item' }, ['Главная']),
          createElement('a', { href: '/about', className: 'nav-item' }, ['О нас']),
          createElement('a', { href: '/contacts', className: 'nav-item' }, ['Контакты'])
        ])
      ])
    ]);
    
    // Создаем основной контент
    const main = createElement('main', {}, [
      createElement('div', { className: 'container' }, [
        // Секция героя
        createElement('section', { className: 'hero' }, [
          createElement('h1', {}, ['Проститутки России | VIP Эскорт услуги']),
          createElement('p', {}, [
            'На нашем сайте представлены элитные проститутки и индивидуалки из 50 городов России. Все анкеты с проверенными фото девушек, предоставляющих VIP эскорт услуги. Выберите город и найдите подходящую девушку для приятного времяпрепровождения.'
          ])
        ]),
        
        // Секция выбора города
        createElement('section', { className: 'selector' }, [
          createElement('div', { className: 'select-group' }, [
            createElement('label', { className: 'select-label' }, ['Город:']),
            createElement('select', { 
              id: 'city-select',
              onchange: function() {
                loadProfiles(this.value);
              }
            }, [
              createElement('option', { value: '' }, ['Все города'])
              // Города будут добавлены динамически
            ])
          ])
        ]),
        
        // Секция профилей
        createElement('section', { id: 'profiles-container', className: 'profiles' })
      ])
    ]);
    
    // Создаем футер
    const footer = createElement('footer', { className: 'footer' }, [
      createElement('div', { className: 'container footer-content' }, [
        createElement('div', { className: 'footer-column' }, [
          createElement('h3', { className: 'footer-title' }, ['О нас']),
          createElement('p', {}, ['Наш сайт предоставляет информацию о VIP эскорт услугах в городах России. Все анкеты проходят тщательную проверку.'])
        ]),
        createElement('div', { className: 'footer-column' }, [
          createElement('h3', { className: 'footer-title' }, ['Информация']),
          createElement('ul', { className: 'footer-links' }, [
            createElement('li', { className: 'footer-link' }, [
              createElement('a', { href: '/terms' }, ['Условия использования'])
            ]),
            createElement('li', { className: 'footer-link' }, [
              createElement('a', { href: '/privacy' }, ['Политика конфиденциальности'])
            ])
          ])
        ]),
        createElement('div', { className: 'footer-column' }, [
          createElement('h3', { className: 'footer-title' }, ['Контакты']),
          createElement('p', {}, ['Email: info@example.com', createElement('br'), '© 2025 VIP Эскорт. Все права защищены.'])
        ])
      ])
    ]);
    
    // Добавляем все элементы в корневой элемент
    root.appendChild(header);
    root.appendChild(main);
    root.appendChild(footer);
  }

  // Функция для загрузки списка городов
  async function loadCities() {
    const cities = await fetchApi('cities');
    const citySelect = document.getElementById('city-select');
    
    if (cities && citySelect) {
      // Сортируем города по алфавиту
      cities.sort((a, b) => a.name.localeCompare(b.name, 'ru'));
      
      cities.forEach(city => {
        const option = createElement('option', { value: city.id }, [city.name]);
        citySelect.appendChild(option);
      });
    }
  }
  
  // Функция для загрузки профилей
  async function loadProfiles(cityId = '') {
    const profilesContainer = document.getElementById('profiles-container');
    if (!profilesContainer) return;
    
    profilesContainer.innerHTML = '';
    
    const endpoint = cityId ? `profiles?cityId=${cityId}` : 'profiles';
    const profiles = await fetchApi(endpoint);
    
    if (!profiles || profiles.length === 0) {
      profilesContainer.appendChild(
        createElement('div', { style: { textAlign: 'center', padding: '40px', width: '100%' } }, [
          'Профили не найдены. Пожалуйста, выберите другой город или повторите попытку позже.'
        ])
      );
      return;
    }
    
    profiles.forEach(profile => {
      const profileCard = createElement('div', { className: 'profile-card' }, [
        createElement('div', { 
          className: 'profile-image',
          style: { 
            backgroundImage: profile.photos && profile.photos.length > 0 ? 
              `url(${profile.photos[0]})` : 'url(https://via.placeholder.com/400x600?text=No+Photo)'
          }
        }),
        createElement('div', { className: 'profile-info' }, [
          createElement('h3', { className: 'profile-name' }, [`${profile.name}, ${profile.age}`]),
          createElement('div', { className: 'profile-details' }, [
            `${profile.height} см, ${profile.weight} кг, грудь ${profile.breastSize}`,
            createElement('br'),
            `${profile.district || ''}`
          ]),
          createElement('div', { className: 'profile-price' }, [`${profile.price1Hour} ₽/час`]),
          createElement('button', { 
            className: 'profile-button',
            onclick: () => showProfileDetails(profile)
          }, ['Смотреть анкету'])
        ])
      ]);
      
      profilesContainer.appendChild(profileCard);
    });
  }
  
  // Функция для отображения подробной информации о профиле
  function showProfileDetails(profile) {
    alert(`Просмотр анкеты: ${profile.name}, ${profile.age}\nТелефон: ${profile.phone}\n\nЭта функция будет доступна в полной версии сайта.`);
  }
  
  // Инициализация приложения
  async function initApp() {
    // Создаем основной макет
    createAppLayout();
    
    // Загружаем данные
    await Promise.all([
      loadCities(),
      loadProfiles()
    ]);
    
    // Скрываем индикатор загрузки
    loadingIndicator.style.display = 'none';
  }

  // Запуск приложения
  initApp();
});
