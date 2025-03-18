const express = require('express');
const router = express.Router();

// Районы города
router.get('/districts/:cityId', (req, res) => {
  const cityId = req.params.cityId;
  console.log(`Запрос районов для города с ID: ${cityId}`);
  
  // Базовый список районов
  const districts = [
    "Центральный", "Северный", "Южный", "Западный", "Восточный",
    "Адмиралтейский", "Василеостровский", "Выборгский", "Калининский",
    "Кировский", "Красногвардейский", "Красносельский", "Московский",
    "Невский", "Петроградский", "Приморский", "Фрунзенский"
  ];
  
  res.json(districts);
});

// Услуги
router.get('/services', (req, res) => {
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

module.exports = router;
