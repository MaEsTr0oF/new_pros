// Создаем простой Express сервер для заглушек API
const express = require('express');
const cors = require('cors');
const app = express();
const port = 3001;

// Включаем CORS
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Логирование запросов
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// API маршрут для districts/:cityId
app.get('/api/districts/:cityId', (req, res) => {
  const cityId = req.params.cityId;
  console.log(`Запрос районов для города с ID: ${cityId}`);
  
  // Список районов
  const districts = [
    "Центральный", "Северный", "Южный", "Западный", "Восточный",
    "Адмиралтейский", "Василеостровский", "Выборгский", "Калининский",
    "Кировский", "Красногвардейский", "Красносельский", "Московский",
    "Невский", "Петроградский", "Приморский", "Фрунзенский"
  ];
  
  res.json(districts);
});

// API маршрут для services
app.get('/api/services', (req, res) => {
  console.log('Запрос списка услуг');
  
  // Список услуг
  const services = [
    "classic", "anal", "oral", "lesbian", "massage",
    "kisses", "blowjob_with_condom", "blowjob_without_condom",
    "deep_blowjob", "anilingus_to_client", "role_play", "foot_fetish",
    "strapon", "mistress", "strip_pro", "strip_amateur"
  ];
  
  res.json(services);
});

// Запуск сервера
app.listen(port, '0.0.0.0', () => {
  console.log(`API-сервер запущен на порту ${port}`);
});
