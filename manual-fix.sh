#!/bin/bash
set -e

echo "🔧 Начинаем ручное исправление проекта..."

# 1. Останавливаем все контейнеры
echo "🛑 Останавливаем контейнеры..."
cd /root/escort-project
docker-compose down

# 2. Создаем все необходимые директории
echo "📁 Создаем необходимые директории..."
mkdir -p /root/escort-project/server/src/middleware
mkdir -p /root/escort-project/client/public

# 3. Добавляем файл middleware для API запросов
echo "🌐 Создаем API middleware..."
cat > /root/escort-project/server/src/middleware/api-middleware.ts << 'MIDDLEWARE_EOF'
import { Request, Response, NextFunction } from 'express';

export const apiMiddleware = (req: Request, res: Response, next: NextFunction) => {
  // Обработка запроса к /api/services
  if (req.path === '/api/services') {
    const services = [
      'classic', 'anal', 'lesbian', 'group_mmf', 'group_ffm', 'with_toys', 'in_car',
      'blowjob_with_condom', 'blowjob_without_condom', 'deep_blowjob', 'car_blowjob',
      'anilingus_to_client', 'fisting_to_client', 'kisses', 'light_domination', 'mistress',
      'flogging', 'trampling', 'face_sitting', 'strapon', 'bondage', 'slave', 'role_play',
      'foot_fetish', 'golden_rain_out', 'golden_rain_in', 'copro_out', 'copro_in', 'enema',
      'relaxing', 'professional', 'body_massage', 'lingam_massage', 'four_hands', 'urological',
      'strip_pro', 'strip_amateur', 'belly_dance', 'twerk', 'lesbian_show', 'sex_chat',
      'phone_sex', 'video_sex', 'photo_video', 'invite_girlfriend', 'invite_friend',
      'escort', 'photoshoot', 'skirt'
    ];
    return res.json(services);
  }

  // Обработка запроса к /api/districts/{cityId}
  if (req.path.match(/^\/api\/districts\/\d+$/)) {
    const districts = [
      'Центральный', 'Адмиралтейский', 'Василеостровский', 'Выборгский', 
      'Калининский', 'Кировский', 'Колпинский', 'Красногвардейский',
      'Красносельский', 'Кронштадтский', 'Курортный', 'Московский',
      'Невский', 'Петроградский', 'Петродворцовый', 'Приморский',
      'Пушкинский', 'Фрунзенский', 'Центральный'
    ];
    return res.json(districts);
  }

  next();
};
MIDDLEWARE_EOF

# 4. Исправляем index.ts, добавляя импорт middleware
echo "📄 Обновляем index.ts..."
cp /root/escort-project/server/src/index.ts /root/escort-project/server/src/index.ts.bak
cat > /root/escort-project/server/src/index.ts << 'INDEX_EOF'
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';
import * as profileController from './controllers/profileController';
import * as cityController from './controllers/cityController';
import * as authController from './controllers/authController';
import * as settingsController from './controllers/settingsController';
import { authMiddleware } from './middleware/auth';
import { apiMiddleware } from './middleware/api-middleware';

dotenv.config();

const app = express();
const prisma = new PrismaClient();
const port = process.env.PORT || 5001;

// Проверка подключения к базе данных
async function checkDatabaseConnection() {
  try {
    await prisma.$connect();
    console.log('✅ Успешное подключение к базе данных');
    
    // Проверяем наличие админа
    const adminCount = await prisma.admin.count();
    if (adminCount === 0) {
      // Создаем дефолтного админа если нет ни одного
      const defaultAdmin = await prisma.admin.create({
        data: {
          username: 'admin',
          password: '$2a$10$K.0HwpsoPDGaB/atFBmmXOGTw4ceeg33.WXgRWQP4hRj0IXIWEkyG', // пароль: admin123
        },
      });
      console.log('✅ Создан дефолтный администратор (логин: admin, пароль: admin123)');
    }

    // Проверяем наличие настроек
    const settingsCount = await prisma.settings.count();
    if (settingsCount === 0) {
      await prisma.settings.create({ data: {} }); // Создаем настройки по умолчанию
      console.log('✅ Созданы настройки по умолчанию');
    }
  } catch (error) {
    console.error('❌ Ошибка подключения к базе данных:', error);
    process.exit(1);
  }
}

// Middleware
app.use(cors({
  origin: process.env.CLIENT_URL || 'https://eskortvsegorodarfreal.site',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Forwarded-Proto', 'X-Real-IP', 'X-Forwarded-For', 'X-Forwarded-Host', 'X-Forwarded-Port']
}));

// Настройка доверенных прокси
app.set('trust proxy', 1);

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Middleware для логирования запросов
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Добавляем middleware для обработки отсутствующих API маршрутов
app.use('/api', apiMiddleware);

// Публичные маршруты
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/profiles', profileController.getProfiles);
app.get('/api/profiles/:id', profileController.getProfileById);
app.get('/api/cities', cityController.getCities);
app.get('/api/settings/public', settingsController.getPublicSettings);

// Маршруты администратора
app.post('/api/auth/login', authController.login);

// Защищенные маршруты (требуют аутентификации)
app.use('/api/admin', authMiddleware);
app.get('/api/admin/profiles', profileController.getProfiles);
app.post('/api/admin/profiles', profileController.createProfile);
app.put('/api/admin/profiles/:id', profileController.updateProfile);
app.delete('/api/admin/profiles/:id', profileController.deleteProfile);
app.patch('/api/admin/profiles/:id/verify', profileController.verifyProfile);
app.post('/api/admin/cities', cityController.createCity);
app.put('/api/admin/cities/:id', cityController.updateCity);
app.delete('/api/admin/cities/:id', cityController.deleteCity);
app.get('/api/admin/settings', settingsController.getSettings);
app.put('/api/admin/settings', settingsController.updateSettings);

// Обработка ошибок
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Что-то пошло не так!' });
});

// Запускаем сервер только после проверки подключения к БД
checkDatabaseConnection().then(() => {
  app.listen(port, () => {
    console.log(`✅ Сервер запущен на порту ${port}`);
    console.log(`📝 Админ-панель доступна по адресу: https://eskortvsegorodarfreal.site/admin`);
    console.log(`🔑 API доступно по адресу: https://eskortvsegorodarfreal.site/api`);
  });
}).catch((error) => {
  console.error('❌ Ошибка запуска сервера:', error);
  process.exit(1);
});
INDEX_EOF

# 5. Исправляем api/index.ts
echo "🔄 Исправляем клиентский API файл..."
cp /root/escort-project/client/src/api/index.ts /root/escort-project/client/src/api/index.ts.bak
cat > /root/escort-project/client/src/api/index.ts << 'API_EOF'
import axios from 'axios';
import { API_URL } from '../config';

// Функция для получения токена из localStorage
export const getToken = () => {
  return localStorage.getItem('auth_token');
};

// Настройка axios с базовым URL
const api = axios.create({
  baseURL: API_URL,
});

// Добавление заголовков авторизации к запросам
export const getAuthHeaders = () => {
  const token = getToken();
  console.log("Auth headers with token:", token ? "Bearer " + token.substring(0, 10) + "..." : "No token");
  return {
    headers: {
      Authorization: token ? `Bearer ${token}` : ''
    }
  };
};

// Добавление интерцептора для добавления токена авторизации ко всем запросам
api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
API_EOF

# 6. Создаем скрипты для отключения Service Worker
echo "📦 Создаем клиентские скрипты..."
cat > /root/escort-project/client/public/disable-sw.js << 'SW_EOF'
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
SW_EOF

# 7. Создаем скрипт для структурированных данных
cat > /root/escort-project/client/public/fix-structured-data.js << 'STRUCT_EOF'
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
STRUCT_EOF

# 8. Создаем SQL-скрипт для сортировки городов
echo "🔤 Создаем SQL-скрипт для сортировки городов..."
cat > /root/escort-project/sort-cities.sql << 'SQL_EOF'
-- Проверяем наличие поля sortOrder в таблице City
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name='City' AND column_name='sortOrder'
  ) THEN
    -- Создаем временную колонку для хранения порядка сортировки
    ALTER TABLE "City" ADD COLUMN "sortOrder" SERIAL;
  END IF;
END$$;

-- Обновляем порядок сортировки в соответствии с алфавитным порядком
WITH sorted_cities AS (
  SELECT 
    id, 
    ROW_NUMBER() OVER (ORDER BY name ASC) AS row_num
  FROM "City"
)
UPDATE "City" 
SET "sortOrder" = sorted_cities.row_num
FROM sorted_cities
WHERE "City".id = sorted_cities.id;

-- Выводим результат для проверки
SELECT id, name, "sortOrder" FROM "City" ORDER BY "sortOrder";
SQL_EOF

# 9. Обновляем файл schema.prisma напрямую
echo "🔧 Обновляем schema.prisma напрямую..."
SCHEMA_FILE="/root/escort-project/server/prisma/schema.prisma"
if [ -f "$SCHEMA_FILE" ]; then
  cp "$SCHEMA_FILE" "${SCHEMA_FILE}.bak"
  # Проверяем наличие поля order в модели Profile
  if ! grep -q "order Int?" "$SCHEMA_FILE"; then
    sed -i '/model Profile {/,/}/s/}$/  order Int?\n}/' "$SCHEMA_FILE"
    echo "✅ Поле order добавлено в модель Profile схемы Prisma"
  else
    echo "✅ Поле order уже существует в схеме Prisma"
  fi
else
  echo "❌ Файл schema.prisma не найден по пути: $SCHEMA_FILE"
fi

# 10. Запускаем контейнеры
echo "🚀 Запускаем контейнеры..."
docker-compose up -d

# 11. Ждем запуск контейнеров
echo "⏳ Ожидаем запуск контейнеров..."
sleep 15

# 12. Копируем клиентские скрипты в контейнер
echo "📋 Копируем скрипты в контейнер..."
docker cp /root/escort-project/client/public/disable-sw.js escort-client:/usr/share/nginx/html/
docker cp /root/escort-project/client/public/fix-structured-data.js escort-client:/usr/share/nginx/html/

# 13. Обновляем index.html для включения скриптов
echo "🖌 Обновляем index.html..."
cat > /tmp/index.html << 'INDEX_HTML_EOF'
<!DOCTYPE html>
<html lang="ru">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta
      name="description"
      content="Эскорт услуги в России. Анкеты VIP девушек с фото и отзывами. Высокий уровень сервиса и конфиденциальность."
    />
    <link rel="apple-touch-icon" href="/logo192.png" />
    <link rel="manifest" href="/manifest.json" />
    <title>Проститутки России | VIP Эскорт услуги</title>
    <!-- Скрипт для отключения Service Worker -->
    <script src="/disable-sw.js"></script>
  </head>
  <body>
    <noscript>Для просмотра сайта необходимо включить JavaScript.</noscript>
    <div id="root"></div>
    <!-- Скрипт для исправления структурированных данных -->
    <script src="/fix-structured-data.js"></script>
  </body>
</html>
INDEX_HTML_EOF

docker cp /tmp/index.html escort-client:/usr/share/nginx/html/index.html

# 14. Применяем SQL для сортировки городов
echo "🔄 Применяем сортировку городов в базе данных..."
docker exec -i escort-postgres psql -U postgres escort_db < /root/escort-project/sort-cities.sql

# 15. Перезапускаем Nginx
echo "🔄 Перезапускаем Nginx..."
docker exec escort-client nginx -s reload

# 16. Запускаем временный API сервер для тестирования
echo "🌐 Запускаем временный API-сервер для тестирования..."
cat > /root/escort-project/temp-api.js << 'TEMP_API_EOF'
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

// Запуск сервера
app.listen(port, () => {
  console.log(`✅ Временный API-сервер запущен на порту ${port}`);
});
TEMP_API_EOF

echo "✅ Все исправления успешно применены!"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
echo ""
echo "⚠️ ВАЖНО: Если основной сервер не запустится из-за ошибки с Prisma, вы можете запустить временный API сервер командой:"
echo "node /root/escort-project/temp-api.js"
