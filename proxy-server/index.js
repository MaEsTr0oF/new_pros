const express = require('express');
const cors = require('cors');
const axios = require('axios');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

// Включаем CORS и парсинг тела запроса
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Основной URL вашего API
const API_URL = 'https://eskortvsegorodarfreal.site/api';

// Логирование запросов
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Обработка запросов к /api/districts/:cityId
app.get('/api/districts/:cityId', (req, res) => {
  const cityId = req.params.cityId;
  console.log(`Запрос районов для города с ID: ${cityId}`);
  
  // Возвращаем статический список районов
  const districts = [
    "Центральный", "Северный", "Южный", "Западный", "Восточный",
    "Адмиралтейский", "Василеостровский", "Выборгский", "Калининский",
    "Кировский", "Красногвардейский", "Красносельский", "Московский",
    "Невский", "Петроградский", "Приморский", "Фрунзенский"
  ];
  
  res.json(districts);
});

// Обработка запросов к /api/services
app.get('/api/services', (req, res) => {
  console.log('Запрос списка услуг');
  
  // Возвращаем статический список услуг
  const services = [
    "classic", "anal", "oral", "lesbian", "massage",
    "kisses", "blowjob_with_condom", "blowjob_without_condom",
    "deep_blowjob", "anilingus_to_client", "role_play", "foot_fetish",
    "strapon", "mistress", "strip_pro", "strip_amateur"
  ];
  
  res.json(services);
});

// Маршрут для перемещения профиля вверх
app.patch('/api/admin/profiles/:id/moveUp', async (req, res) => {
  try {
    const { id } = req.params;
    const headers = {
      'Authorization': req.headers.authorization
    };
    
    // Запрос к реальному API
    const response = await axios.patch(`${API_URL}/admin/profiles/${id}/moveUp`, {}, { headers });
    res.json(response.data);
  } catch (error) {
    console.error('Ошибка при перемещении профиля вверх:', error.message);
    res.status(500).json({ error: 'Не удалось переместить профиль вверх' });
  }
});

// Маршрут для перемещения профиля вниз
app.patch('/api/admin/profiles/:id/moveDown', async (req, res) => {
  try {
    const { id } = req.params;
    const headers = {
      'Authorization': req.headers.authorization
    };
    
    // Запрос к реальному API
    const response = await axios.patch(`${API_URL}/admin/profiles/${id}/moveDown`, {}, { headers });
    res.json(response.data);
  } catch (error) {
    console.error('Ошибка при перемещении профиля вниз:', error.message);
    res.status(500).json({ error: 'Не удалось переместить профиль вниз' });
  }
});

// Запуск сервера
app.listen(port, '0.0.0.0', () => {
  console.log(`Сервер-посредник запущен на порту ${port}`);
});
