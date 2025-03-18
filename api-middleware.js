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
app.use(express.json());

// Маршруты для районов
app.get('/api/districts/:cityId', (req, res) => {
  console.log('Запрос районов для города:', req.params.cityId);
  res.json([
    "Центральный", 
    "Северный", 
    "Южный", 
    "Западный", 
    "Восточный"
  ]);
});

// Маршруты для услуг
app.get('/api/services', (req, res) => {
  console.log('Запрос списка услуг');
  res.json([
    "classic", 
    "anal", 
    "oral", 
    "massage", 
    "kisses", 
    "blowjob_with_condom", 
    "blowjob_without_condom"
  ]);
});

// Другие необходимые маршруты
app.get('/api/profiles', (req, res) => {
  const existingServer = 'http://localhost:5001/api/profiles';
  console.log('Перенаправление запроса профилей');
  res.redirect(307, existingServer + '?' + new URLSearchParams(req.query).toString());
});

// Перенаправление остальных запросов на основной сервер
app.all('/api/*', (req, res) => {
  const path = req.path.substring(4); // Убираем /api из пути
  console.log('Перенаправление запроса:', req.method, path);
  res.redirect(307, 'http://localhost:5001' + req.originalUrl);
});

// Запуск сервера
app.listen(5002, () => {
  console.log('API-middleware запущен на порту 5002');
});
