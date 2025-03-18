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
app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Временный API-сервер запущен на порту ${port}`);
});
