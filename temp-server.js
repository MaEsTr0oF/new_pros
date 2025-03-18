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

// Общий список профилей
const profilesList = [
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
    price2Hours: 9000,
    priceNight: 25000,
    priceExpress: 2500,
    workingHours: "24/7",
    isVerified: true,
    hasVideo: false,
    hasReviews: true,
    services: ["classic", "anal", "massage"],
    cityId: 1,
    district: "Центральный",
    isActive: true,
    gender: "Женщины",
    verification: ["Верифицирован"],
    createdAt: "2023-01-15T14:30:00.000Z",
    updatedAt: "2023-05-20T10:15:00.000Z"
  }
];

// Маршруты API
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Районы (временный эндпоинт)
app.get('/api/districts/:cityId', (req, res) => {
  console.log('Districts API called for city ID:', req.params.cityId);
  const districts = ["Центральный", "Северный", "Южный", "Западный", "Восточный"];
  res.json(districts);
});

// Услуги (временный эндпоинт)
app.get('/api/services', (req, res) => {
  console.log('Services API called');
  const services = ["classic", "anal", "oral", "massage", "kisses"];
  res.json(services);
});

// Запуск сервера
app.listen(port, () => {
  console.log(`✅ Временный API-сервер запущен на порту ${port}`);
});
