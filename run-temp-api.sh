#!/bin/bash
# Проверяем, запущен ли контейнер сервера
if [ ! "$(docker ps -q -f name=escort-server)" ]; then
  echo "Сервер не запущен, запускаем временный API"
  
  # Проверяем наличие файла temp-api.js
  if [ ! -f "/root/escort-project/temp-api.js" ]; then
    echo "Файл temp-api.js не найден, создаем его"
    cat > /root/escort-project/temp-api.js << 'API_EOF'
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
  res.json(cities);
});

// Профили (временный эндпоинт)
app.get('/api/profiles', (req, res) => {
  const profiles = [
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
    }
  ];
  res.json(profiles);
});

// Запуск сервера
app.listen(port, () => {
  console.log(`✅ Временный API-сервер запущен на порту ${port}`);
});
API_EOF
  fi

  # Проверяем, установлен ли Node.js
  if ! [ -x "$(command -v node)" ]; then
    echo "Node.js не установлен, устанавливаем..."
    apt-get update
    apt-get install -y nodejs npm
  fi

  # Проверяем, установлен ли express
  if [ ! -d "/root/escort-project/node_modules/express" ]; then
    echo "Express не установлен, устанавливаем..."
    cd /root/escort-project
    npm install express cors
  fi

  # Запускаем API сервер
  echo "Запускаем временный API сервер..."
  nohup node /root/escort-project/temp-api.js > /root/escort-project/temp-api.log 2>&1 &
  echo "Временный API сервер запущен в фоновом режиме"
  echo "Логи доступны в файле: /root/escort-project/temp-api.log"
else
  echo "Сервер уже запущен"
fi
