#!/bin/bash
set -e

echo "🔧 Восстанавливаем React-приложение..."

# Директория проекта
PROJECT_DIR="/root/escort-project"
CLIENT_DIR="$PROJECT_DIR/client"

# 1. Проверяем, существует ли директория клиента
if [ ! -d "$CLIENT_DIR" ]; then
  echo "❌ Директория клиента не найдена: $CLIENT_DIR"
  exit 1
fi

# 2. Создаем простой HTML-файл с базовой структурой приложения
echo "📝 Создаем базовую HTML-страницу..."
cat > /tmp/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Эскорт услуги в России. Анкеты VIP девушек с фото и отзывами.">
  <title>Проститутки России | VIP Эскорт услуги</title>
  <link rel="icon" href="/favicon.ico">
  <link rel="stylesheet" href="/static/css/main.css">
  <script src="/disable-sw.js"></script>
</head>
<body>
  <div id="root"></div>
  <script src="/static/js/main.js"></script>
  <script src="/fix-structured-data.js"></script>
</body>
</html>
HTML_EOF

# 3. Создаем основные JavaScript и CSS файлы
echo "�� Создаем основные JS/CSS файлы..."

mkdir -p /tmp/static/js
mkdir -p /tmp/static/css

# Основной JS файл
cat > /tmp/static/js/main.js << 'JS_EOF'
document.addEventListener('DOMContentLoaded', function() {
  // Функция для создания запроса к API
  function fetchAPI(endpoint) {
    return fetch('/api/' + endpoint)
      .then(response => {
        if (!response.ok) {
          throw new Error('Ошибка сети: ' + response.status);
        }
        return response.json();
      })
      .catch(error => {
        console.error('Ошибка API:', error);
        return [];
      });
  }

  // Функция для создания элемента DOM
  function createElement(tag, props = {}, children = []) {
    const element = document.createElement(tag);
    
    Object.entries(props).forEach(([key, value]) => {
      if (key === 'className') {
        element.className = value;
      } else if (key === 'style') {
        Object.entries(value).forEach(([cssKey, cssValue]) => {
          element.style[cssKey] = cssValue;
        });
      } else if (key.startsWith('on') && typeof value === 'function') {
        element.addEventListener(key.substring(2).toLowerCase(), value);
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

  // Создаем основную структуру приложения
  const app = document.getElementById('root');
  if (!app) return;

  // Создаем хедер
  const header = createElement('header', {
    className: 'header',
  }, [
    createElement('div', { className: 'container' }, [
      createElement('h1', {}, ['VIP Эскорт']),
      createElement('div', { className: 'city-selector' }, [
        createElement('select', { 
          id: 'city-select',
          onchange: function() {
            loadProfiles(this.value);
          }
        }, [
          createElement('option', { value: '' }, ['Выберите город']),
          // Города будут добавлены динамически
        ])
      ])
    ])
  ]);

  // Создаем основной контент
  const content = createElement('main', {
    className: 'main-content'
  }, [
    createElement('div', { className: 'container' }, [
      createElement('div', { className: 'welcome-text' }, [
        createElement('h2', {}, ['Проститутки России | VIP Эскорт услуги']),
        createElement('p', {}, [
          'На нашем сайте представлены элитные проститутки и индивидуалки из 50 городов России. Все анкеты с проверенными фото девушек, предоставляющих VIP эскорт услуги. Выберите город и найдите подходящую девушку для приятного времяпрепровождения.'
        ])
      ]),
      createElement('div', { id: 'profiles-container', className: 'profiles-grid' }, [
        // Профили будут добавлены динамически
        createElement('div', { className: 'loading' }, ['Загрузка профилей...'])
      ])
    ])
  ]);

  // Создаем футер
  const footer = createElement('footer', {
    className: 'footer'
  }, [
    createElement('div', { className: 'container' }, [
      createElement('p', {}, ['© ' + new Date().getFullYear() + ' VIP Эскорт услуги. Все права защищены.'])
    ])
  ]);

  // Добавляем все элементы на страницу
  app.appendChild(header);
  app.appendChild(content);
  app.appendChild(footer);

  // Функция для загрузки городов
  function loadCities() {
    fetchAPI('cities')
      .then(cities => {
        const citySelect = document.getElementById('city-select');
        if (!citySelect) return;

        // Сортируем города по алфавиту
        cities.sort((a, b) => a.name.localeCompare(b.name, 'ru'));
        
        // Добавляем города в выпадающий список
        cities.forEach(city => {
          const option = createElement('option', { value: city.id }, [city.name]);
          citySelect.appendChild(option);
        });
      });
  }

  // Функция для загрузки профилей
  function loadProfiles(cityId) {
    const profilesContainer = document.getElementById('profiles-container');
    if (!profilesContainer) return;
    
    profilesContainer.innerHTML = '<div class="loading">Загрузка профилей...</div>';
    
    let url = 'profiles';
    if (cityId) {
      url += '?cityId=' + cityId;
    }
    
    fetchAPI(url)
      .then(profiles => {
        profilesContainer.innerHTML = '';
        
        if (profiles.length === 0) {
          profilesContainer.innerHTML = '<div class="no-profiles">Профили не найдены</div>';
          return;
        }
        
        profiles.forEach(profile => {
          const profileCard = createElement('div', { className: 'profile-card' }, [
            createElement('div', { 
              className: 'profile-image',
              style: { backgroundImage: profile.photos && profile.photos.length > 0 ? 
                `url(${profile.photos[0]})` : 'none' 
              }
            }),
            createElement('div', { className: 'profile-info' }, [
              createElement('h3', {}, [`${profile.name}, ${profile.age}`]),
              createElement('p', {}, [`${profile.height} см, ${profile.weight} кг, грудь ${profile.breastSize}`]),
              createElement('p', { className: 'price' }, [`${profile.price1Hour} ₽/час`]),
              createElement('button', { 
                className: 'view-btn',
                onclick: function() {
                  alert(`Анкета ${profile.name} (ID: ${profile.id})`);
                }
              }, ['Смотреть анкету'])
            ])
          ]);
          
          profilesContainer.appendChild(profileCard);
        });
      });
  }

  // Загружаем данные при загрузке страницы
  loadCities();
  loadProfiles();

  // Добавляем статус API
  const apiStatus = createElement('div', { 
    id: 'api-status',
    style: { 
      position: 'fixed',
      bottom: '10px',
      right: '10px',
      padding: '10px',
      background: 'rgba(0,0,0,0.7)',
      color: 'white',
      borderRadius: '5px',
      fontSize: '12px',
      zIndex: 1000
    }
  }, ['Проверка API...']);
  
  document.body.appendChild(apiStatus);
  
  // Проверяем статус API
  fetch('/api/health')
    .then(response => response.json())
    .then(data => {
      apiStatus.textContent = `API: ✅ (${data.timestamp || 'OK'})`;
      setTimeout(() => {
        apiStatus.style.opacity = '0.5';
      }, 3000);
    })
    .catch(error => {
      apiStatus.textContent = `API: ❌ (${error.message})`;
      apiStatus.style.background = 'rgba(255,0,0,0.7)';
    });
});
JS_EOF

# Основной CSS файл
cat > /tmp/static/css/main.css << 'CSS_EOF'
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: Arial, sans-serif;
  line-height: 1.6;
  color: #333;
  background-color: #f5f5f5;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 15px;
}

.header {
  background: linear-gradient(to right, #8e2de2, #4a00e0);
  color: white;
  padding: 20px 0;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.header h1 {
  margin: 0;
  font-size: 28px;
}

.city-selector {
  margin-top: 10px;
}

.city-selector select {
  padding: 8px 15px;
  border: none;
  border-radius: 4px;
  width: 200px;
  font-size: 16px;
}

.main-content {
  padding: 30px 0;
}

.welcome-text {
  text-align: center;
  margin-bottom: 30px;
}

.welcome-text h2 {
  font-size: 32px;
  margin-bottom: 15px;
  color: #8e2de2;
}

.welcome-text p {
  max-width: 800px;
  margin: 0 auto;
  color: #666;
}

.profiles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 30px;
}

.profile-card {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 3px 10px rgba(0,0,0,0.1);
  transition: transform 0.3s;
}

.profile-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 20px rgba(0,0,0,0.15);
}

.profile-image {
  height: 250px;
  background-color: #ddd;
  background-size: cover;
  background-position: center;
}

.profile-info {
  padding: 15px;
}

.profile-info h3 {
  font-size: 18px;
  margin-bottom: 5px;
}

.profile-info p {
  color: #666;
  margin-bottom: 10px;
}

.profile-info .price {
  font-weight: bold;
  color: #8e2de2;
  font-size: 18px;
}

.view-btn {
  display: block;
  width: 100%;
  padding: 10px;
  background-color: #8e2de2;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  margin-top: 10px;
  font-size: 16px;
  transition: background-color 0.3s;
}

.view-btn:hover {
  background-color: #7621c7;
}

.footer {
  background: #333;
  color: white;
  padding: 20px 0;
  text-align: center;
  margin-top: 40px;
}

.loading {
  text-align: center;
  padding: 50px;
  color: #666;
  font-style: italic;
}

.no-profiles {
  text-align: center;
  padding: 50px;
  color: #666;
}

@media (max-width: 768px) {
  .profiles-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  }
  
  .welcome-text h2 {
    font-size: 24px;
  }
}

@media (max-width: 480px) {
  .profiles-grid {
    grid-template-columns: 1fr;
  }
  
  .header h1 {
    font-size: 24px;
  }
  
  .city-selector select {
    width: 100%;
  }
}
CSS_EOF

# 4. Создаем скрипты для исправления проблем
echo "📝 Создаем вспомогательные скрипты..."

# Скрипт для отключения Service Worker
cat > /tmp/disable-sw.js << 'DISABLE_SW_EOF'
(function() {
  // Проверяем поддержку Service Worker
  if ('serviceWorker' in navigator) {
    // Находим все регистрации Service Worker и удаляем их
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
      console.log("Найдено регистраций Service Worker:", registrations.length);
      if (registrations.length > 0) {
        for(let registration of registrations) {
          registration.unregister();
          console.log('Service Worker отключен:', registration);
        }
        // Перезагружаем страницу чтобы убедиться что SW больше не работает
        if (window.caches) {
          caches.keys().then(function(names) {
            for (let name of names) {
              caches.delete(name);
              console.log('Кэш удален:', name);
            }
          });
        }
        console.log("Все регистрации Service Worker удалены");
      }
    }).catch(function(error) {
      console.log('Ошибка при отключении Service Worker:', error);
    });

    // Переопределяем метод register для предотвращения регистрации новых Service Worker
    const originalRegister = navigator.serviceWorker.register;
    navigator.serviceWorker.register = function() {
      console.warn('🛑 Попытка регистрации Service Worker заблокирована');
      return Promise.reject(new Error('Регистрация Service Worker отключена'));
    };
    
    console.log('Регистрация Service Worker заблокирована');
  }
})();
DISABLE_SW_EOF

# Скрипт для исправления структурированных данных
cat > /tmp/fix-structured-data.js << 'FIX_STRUCT_EOF'
(function() {
  // Функция для перемещения структурированных данных в head документа
  function fixStructuredData() {
    // Ищем все элементы script с типом application/ld+json
    const jsonScripts = document.querySelectorAll('script[type="application/ld+json"]');
    
    // Если найдены JSON скрипты в неправильном месте
    if (jsonScripts.length > 0) {
      console.log("Найдены структурированные данные, перемещаем в head...");
      
      // Перемещаем каждый скрипт в head
      jsonScripts.forEach(script => {
        // Копируем содержимое скрипта
        const content = script.textContent;
        const type = script.type;
        
        // Создаем новый скрипт в head
        const newScript = document.createElement('script');
        newScript.type = type;
        newScript.textContent = content;
        
        // Добавляем в head
        document.head.appendChild(newScript);
        
        // Удаляем оригинальный скрипт
        script.parentNode.removeChild(script);
      });
      
      console.log("Структурированные данные успешно перенесены в head.");
    }
  }
  
  // Запускаем исправление после загрузки страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fixStructuredData);
  } else {
    fixStructuredData();
  }
})();
FIX_STRUCT_EOF

# 5. Копируем все файлы в контейнер
echo "📋 Копируем файлы в контейнер..."
docker cp /tmp/index.html escort-client:/usr/share/nginx/html/index.html
docker cp /tmp/static escort-client:/usr/share/nginx/html/
docker cp /tmp/disable-sw.js escort-client:/usr/share/nginx/html/disable-sw.js
docker cp /tmp/fix-structured-data.js escort-client:/usr/share/nginx/html/fix-structured-data.js

# 6. Перезапускаем Nginx
echo "🔄 Перезапускаем Nginx..."
docker exec escort-client nginx -s reload

# 7. Запускаем временный API сервер
echo "🌐 Проверяем статус API сервера..."
API_SERVER_RUNNING=$(docker ps -q -f name=escort-server)

if [ -z "$API_SERVER_RUNNING" ]; then
  echo "⚠️ API сервер не запущен, создаем временный сервер..."
  
  # Создаем временный API сервер
  cat > $PROJECT_DIR/temp-api.js << 'TEMP_API_EOF'
const express = require('express');
const cors = require('cors');
const app = express();
const port = 5001;

// Включаем middleware
app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Маршруты API
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Услуги (временный эндпоинт)
app.get('/api/services', (req, res) => {
  const services = [
    'classic', 'anal', 'lesbian', 'group_mmf', 'group_ffm', 'with_toys', 'in_car',
    'blowjob_with_condom', 'blowjob_without_condom', 'deep_blowjob', 'car_blowjob',
    'anilingus_to_client', 'fisting_to_client', 'kisses', 'light_domination', 'mistress'
  ];
  res.json(services);
});

// Районы (временный эндпоинт)
app.get('/api/districts/:cityId', (req, res) => {
  const districts = ["Центральный", "Северный", "Южный", "Западный", "Восточный"];
  res.json(districts);
});

// Города (временный эндпоинт)
app.get('/api/cities', (req, res) => {
  const cities = [
    { id: 1, name: "Москва", code: "moscow" },
    { id: 2, name: "Санкт-Петербург", code: "spb" },
    { id: 3, name: "Екатеринбург", code: "ekb" },
    { id: 4, name: "Новосибирск", code: "nsk" },
    { id: 5, name: "Казань", code: "kazan" },
    { id: 6, name: "Краснодар", code: "krasnodar" },
    { id: 7, name: "Сочи", code: "sochi" },
    { id: 8, name: "Ростов-на-Дону", code: "rostov" }
  ];
  res.json(cities.sort((a, b) => a.name.localeCompare(b.name, 'ru')));
});

// Профили (временный эндпоинт)
app.get('/api/profiles', (req, res) => {
  const cityId = req.query.cityId ? parseInt(req.query.cityId) : null;
  
  const allProfiles = [
    {
      id: 1,
      name: "Алиса",
      age: 22,
      height: 170,
      weight: 55,
      breastSize: 3,
      phone: "+7 (999) 123-45-67",
      description: "Привлекательная блондинка. Приглашаю в гости для приятного времяпрепровождения.",
      photos: [
        "https://via.placeholder.com/400x600?text=Photo+1",
        "https://via.placeholder.com/400x600?text=Photo+2"
      ],
      price1Hour: 5000,
      cityId: 1,
      district: "Центральный",
      isActive: true,
      gender: "female"
    },
    {
      id: 2,
      name: "Мария",
      age: 25,
      height: 165,
      weight: 52,
      breastSize: 2,
      phone: "+7 (999) 765-43-21",
      description: "Страстная брюнетка приглашает в свои апартаменты. Индивидуально.",
      photos: [
        "https://via.placeholder.com/400x600?text=Photo+3",
        "https://via.placeholder.com/400x600?text=Photo+4"
      ],
      price1Hour: 6000,
      cityId: 1,
      district: "Южный",
      isActive: true,
      gender: "female"
    },
    {
      id: 3,
      name: "Ирина",
      age: 24,
      height: 168,
      weight: 54,
      breastSize: 3,
      phone: "+7 (999) 111-22-33",
      description: "Опытная, ласковая девушка. Приглашаю в гости порядочного мужчину.",
      photos: [
        "https://via.placeholder.com/400x600?text=Photo+5",
        "https://via.placeholder.com/400x600?text=Photo+6"
      ],
      price1Hour: 5500,
      cityId: 2,
      district: "Центральный",
      isActive: true,
      gender: "female"
    },
    {
      id: 4,
      name: "Елена",
      age: 23,
      height: 172,
      weight: 56,
      breastSize: 3,
      phone: "+7 (999) 444-55-66",
      description: "Исполню любые твои желания. Жду звонка.",
      photos: [
        "https://via.placeholder.com/400x600?text=Photo+7",
        "https://via.placeholder.com/400x600?text=Photo+8"
      ],
      price1Hour: 6500,
      cityId: 2,
      district: "Северный",
      isActive: true,
      gender: "female"
    }
  ];
  
  // Фильтруем профили по городу, если указан cityId
  const profiles = cityId 
    ? allProfiles.filter(profile => profile.cityId === cityId)
    : allProfiles;
    
  res.json(profiles);
});

// Запуск сервера
app.listen(port, () => {
  console.log(`✅ Временный API-сервер запущен на порту ${port}`);
});
TEMP_API_EOF

  # Проверяем наличие Node.js и express
  if ! command -v node &> /dev/null; then
    echo "❌ Node.js не установлен. Пожалуйста, установите его командой: apt-get update && apt-get install -y nodejs npm"
    exit 1
  fi
  
  # Устанавливаем express, если его нет
  if [ ! -d "$PROJECT_DIR/node_modules/express" ]; then
    echo "📦 Устанавливаем express..."
    cd $PROJECT_DIR
    npm install express cors
  fi
  
  # Запускаем API сервер
  echo "🚀 Запускаем временный API сервер..."
  cd $PROJECT_DIR
  nohup node temp-api.js > temp-api.log 2>&1 &
  echo "✅ Временный API сервер запущен в фоновом режиме. Логи доступны в $PROJECT_DIR/temp-api.log"
else
  echo "✅ API сервер уже запущен"
fi

echo "✅ Приложение успешно восстановлено!"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
echo ""
echo "⚠️ Примечание: это временная замена React-приложения, которая предоставляет базовую функциональность."
echo "   Для полного восстановления исходного React-приложения потребуется пересобрать его из исходников."
