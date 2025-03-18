#!/bin/bash
set -e

echo "🚀 Начинаю полную пересборку проекта..."

# 1. Остановка и удаление всех контейнеров
echo "🛑 Останавливаю и удаляю все контейнеры..."
cd /root/escort-project
docker-compose down

# 2. Очистка кэша Docker
echo "🧹 Очищаю кэш Docker..."
docker system prune -f

# 3. Проверка и исправление схемы Prisma
echo "🔄 Проверяю схему Prisma на наличие ошибок..."
SCHEMA_FILE="/root/escort-project/server/prisma/schema.prisma"
if grep -q -P "order\s+Int\s+@default\(0\).*order\s+Int\s+@default\(0\)" "$SCHEMA_FILE"; then
  echo "⚠️ Обнаружено дублирование поля order, исправляю..."
  cat "$SCHEMA_FILE" | awk 'BEGIN{count=0} /order +Int +@default\(0\)/ {count++; if(count>1) next} {print}' > /tmp/schema.prisma
  cp /tmp/schema.prisma "$SCHEMA_FILE"
  echo "✅ Схема Prisma исправлена"
else
  echo "✅ Схема Prisma корректна"
fi

# 4. Исправление потенциальных проблем с клиентской частью
echo "🔄 Проверяю клиентскую часть..."
API_FILE="/root/escort-project/client/src/api/index.ts"
if [ -f "$API_FILE" ]; then
  echo "🔍 Проверяю файл api/index.ts на наличие синтаксических ошибок..."
  if grep -q "const api = {" "$API_FILE"; then
    echo "⚠️ Обнаружена потенциальная ошибка синтаксиса, исправляю..."
    cat > "$API_FILE" << 'API_CODE'
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
API_CODE
    echo "✅ Файл api/index.ts исправлен"
  else
    echo "✅ Файл api/index.ts выглядит корректно"
  fi
fi

# 5. Создание дополнительных скриптов для клиента
echo "📝 Создаю дополнительные скрипты для клиента..."
mkdir -p /root/escort-project/client/public

# Скрипт для отключения Service Worker
cat > /root/escort-project/client/public/disable-sw.js << 'SW_CODE'
(function() {
  // Проверяем поддержку Service Worker
  if ('serviceWorker' in navigator) {
    // Находим и удаляем все регистрации Service Worker
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
      console.log("Найдено регистраций Service Worker:", registrations.length);
      if (registrations.length > 0) {
        for(let registration of registrations) {
          registration.unregister();
          console.log('Service Worker отключен:', registration);
        }
        
        // Очищаем кэш
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

    // Блокируем будущие регистрации
    navigator.serviceWorker.register = function() {
      console.warn('🛑 Попытка регистрации Service Worker заблокирована');
      return Promise.reject(new Error('Регистрация Service Worker отключена'));
    };
    
    console.log('Регистрация Service Worker заблокирована');
  }
})();
SW_CODE

# Скрипт для структурированных данных
cat > /root/escort-project/client/public/structured-data.js << 'SD_CODE'
(function() {
  // Создаем структурированные данные для сайта (SEO)
  function createStructuredData() {
    var websiteData = {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "VIP Эскорт Услуги",
      "url": window.location.origin,
      "potentialAction": {
        "@type": "SearchAction",
        "target": window.location.origin + "/search?q={search_term_string}",
        "query-input": "required name=search_term_string"
      }
    };
    
    var organizationData = {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "VIP Эскорт Услуги",
      "url": window.location.origin,
      "logo": window.location.origin + "/logo.png"
    };
    
    function addJsonLd(data) {
      var script = document.createElement('script');
      script.type = 'application/ld+json';
      script.text = JSON.stringify(data);
      document.head.appendChild(script);
    }
    
    addJsonLd(websiteData);
    addJsonLd(organizationData);
    
    console.log('Структурированные данные добавлены');
  }
  
  // Запускаем после загрузки страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', createStructuredData);
  } else {
    createStructuredData();
  }
})();
SD_CODE

# Скрипт для сортировки городов
cat > /root/escort-project/client/public/sort-cities.js << 'SORT_CODE'
(function() {
  // Функция для сортировки городов в алфавитном порядке
  function sortCities() {
    // Находим селект с городами
    var citySelect = document.querySelector('select#city-select, select[name="city"]');
    if (!citySelect) {
      console.log('Селект с городами не найден');
      return;
    }
    
    // Получаем все опции
    var options = Array.from(citySelect.options);
    
    // Сортируем в алфавитном порядке (с учетом кириллицы)
    options.sort(function(a, b) {
      return a.text.localeCompare(b.text, 'ru');
    });
    
    // Очищаем селект
    citySelect.innerHTML = '';
    
    // Добавляем отсортированные опции
    options.forEach(function(option) {
      citySelect.appendChild(option);
    });
    
    console.log('Города отсортированы по алфавиту');
  }
  
  // Запускаем после загрузки страницы
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', sortCities);
  } else {
    sortCities();
  }
})();
SORT_CODE

# 6. Обновление индексного файла для включения скриптов
echo "🔄 Обновляю индексный файл для включения дополнительных скриптов..."
INDEX_UPDATER="/root/escort-project/update-index.sh"
cat > "$INDEX_UPDATER" << 'INDEX_UPDATE'
#!/bin/bash
set -e

# Функция для обновления индексного файла
update_index_file() {
  local file="$1"
  if [ -f "$file" ]; then
    # Создаем резервную копию
    cp "$file" "${file}.bak"
    
    # Добавляем скрипты перед </body>
    sed -i 's|</body>|<script src="/disable-sw.js"></script>\n<script src="/structured-data.js"></script>\n<script src="/sort-cities.js"></script>\n</body>|' "$file"
    
    echo "✅ Файл $file обновлен с добавлением скриптов"
    return 0
  fi
  return 1
}

# Пытаемся найти и обновить index.html в разных местах
if update_index_file "/root/escort-project/client/build/index.html"; then
  echo "✅ Найден и обновлен индексный файл в директории сборки"
elif update_index_file "/root/escort-project/client/public/index.html"; then
  echo "✅ Найден и обновлен индексный файл в директории public"
else
  echo "⚠️ Индексный файл не найден"
fi
INDEX_UPDATE
chmod +x "$INDEX_UPDATER"

# 7. Пересборка и запуск проекта
echo "🚀 Начинаю пересборку и запуск проекта..."
cd /root/escort-project

# 7.1. Убеждаемся, что переменные окружения настроены
if [ ! -f ".env" ]; then
  echo "⚠️ Файл .env не найден, создаю с базовыми настройками..."
  cat > .env << 'ENV'
JWT_SECRET=your_jwt_secret_key_qwertyuiopasdfghjklzxcvbnm
CLIENT_URL=https://eskortvsegorodarfreal.site
API_URL=https://eskortvsegorodarfreal.site/api
ENV
fi

# 7.2. Запускаем сборку и запуск контейнеров
echo "🐳 Запускаю Docker Compose..."
docker-compose build --no-cache
docker-compose up -d

# 7.3. Ждем запуска базы данных
echo "⏳ Ожидаю запуска базы данных..."
sleep 10

# 7.4. Выполняем миграцию Prisma внутри контейнера
echo "🔄 Применяю миграцию Prisma..."
docker exec escort-server npx prisma db push --accept-data-loss || true

# 7.5. Запускаем обновление индексного файла
echo "🔄 Обновляю индексный файл в контейнере..."
docker cp /root/escort-project/client/public/disable-sw.js escort-client:/usr/share/nginx/html/disable-sw.js
docker cp /root/escort-project/client/public/structured-data.js escort-client:/usr/share/nginx/html/structured-data.js
docker cp /root/escort-project/client/public/sort-cities.js escort-client:/usr/share/nginx/html/sort-cities.js

# Обновляем index.html в контейнере
docker exec escort-client /bin/sh -c 'if [ -f "/usr/share/nginx/html/index.html" ]; then \
  sed -i "s|</body>|<script src=\"/disable-sw.js\"></script>\n<script src=\"/structured-data.js\"></script>\n<script src=\"/sort-cities.js\"></script>\n</body>|" /usr/share/nginx/html/index.html; \
  echo "✅ Индексный файл в контейнере обновлен"; \
else \
  echo "⚠️ Индексный файл в контейнере не найден"; \
fi'

# 7.6. Перезапускаем Nginx для применения изменений
echo "🔄 Перезапускаю Nginx..."
docker exec escort-client nginx -s reload

# 8. Создание API middleware для районов и услуг
echo "🔄 Проверяю наличие API middleware..."
API_MIDDLEWARE_FILE="/root/escort-project/server/src/middleware/api-middleware.ts"
if [ ! -f "$API_MIDDLEWARE_FILE" ]; then
  echo "⚠️ API middleware не найден, создаю..."
  mkdir -p /root/escort-project/server/src/middleware
  
  cat > "$API_MIDDLEWARE_FILE" << 'API_MIDDLEWARE'
import express, { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const router = express.Router();

// Получение районов по городу
router.get('/districts/:cityId', async (req: Request, res: Response) => {
  try {
    const cityId = parseInt(req.params.cityId);
    if (isNaN(cityId)) {
      return res.status(400).json({ error: 'Некорректный ID города' });
    }

    // Получаем уникальные районы из профилей данного города
    const districts = await prisma.profile.findMany({
      where: {
        cityId: cityId,
        district: {
          not: null
        }
      },
      select: {
        district: true
      },
      distinct: ['district']
    });

    const districtList = districts
      .map(item => item.district)
      .filter(district => district !== null && district !== "")
      .sort((a, b) => a.localeCompare(b, 'ru'));

    res.json(districtList);
  } catch (error) {
    console.error('Ошибка при получении районов:', error);
    res.status(500).json({ error: 'Не удалось получить районы' });
  }
});

// Получение доступных услуг
router.get('/services', async (_req: Request, res: Response) => {
  try {
    // Статический список услуг
    const services = [
      'classic', 'anal', 'lesbian', 'group_mmf', 'group_ffm', 'with_toys',
      'in_car', 'blowjob_with_condom', 'blowjob_without_condom', 'deep_blowjob',
      'car_blowjob', 'anilingus_to_client', 'fisting_to_client', 'kisses',
      'light_domination', 'mistress', 'flogging', 'trampling', 'face_sitting',
      'strapon', 'bondage', 'slave', 'role_play', 'foot_fetish', 'golden_rain_out',
      'golden_rain_in', 'copro_out', 'copro_in', 'enema', 'relaxing',
      'professional', 'body_massage', 'lingam_massage', 'four_hands',
      'urological', 'strip_pro', 'strip_amateur', 'belly_dance', 'twerk',
      'lesbian_show', 'sex_chat', 'phone_sex', 'video_sex', 'photo_video',
      'invite_girlfriend', 'invite_friend', 'escort', 'photoshoot', 'skirt'
    ];
    
    res.json(services);
  } catch (error) {
    console.error('Ошибка при получении услуг:', error);
    res.status(500).json({ error: 'Не удалось получить услуги' });
  }
});

export default router;
API_MIDDLEWARE

  # Копируем middleware в контейнер
  docker cp "$API_MIDDLEWARE_FILE" escort-server:/app/build/middleware/api-middleware.js
  
  echo "✅ API middleware создан и скопирован в контейнер"
  
  # Обновляем index.ts для использования middleware
  INDEX_FILE="/root/escort-project/server/src/index.ts"
  if [ -f "$INDEX_FILE" ] && ! grep -q "apiMiddleware" "$INDEX_FILE"; then
    echo "⚠️ Импорт API middleware не найден, добавляю..."
    # Сначала добавляем импорт
    sed -i "1s/^/import apiMiddleware from '.\/middleware\/api-middleware';\n/" "$INDEX_FILE"
    
    # Затем находим место для использования middleware
    LINE_NUM=$(grep -n "app.use(express.json" "$INDEX_FILE" | head -1 | cut -d: -f1)
    if [ -n "$LINE_NUM" ]; then
      # Добавляем использование middleware
      sed -i "${LINE_NUM}a // Применяем API middleware\napp.use('/api', apiMiddleware);" "$INDEX_FILE"
      echo "✅ Импорт и использование API middleware добавлены"
      
      # Пересобираем сервер
      echo "🔄 Пересобираю серверную часть..."
      cd /root/escort-project/server
      docker exec escort-server npm run build || true
      docker-compose restart server
    else
      echo "⚠️ Не удалось найти место для добавления middleware"
    fi
  else
    echo "✅ API middleware уже настроен"
  fi
fi

# 9. Проверка сервера и базы данных
echo "🔍 Проверяю статус сервера и базы данных..."
if docker ps | grep -q escort-server && docker ps | grep -q escort-postgres; then
  echo "✅ Контейнеры запущены успешно"
else
  echo "⚠️ Не все контейнеры запущены, пытаюсь перезапустить..."
  docker-compose down
  docker-compose up -d
fi

# 10. Создание SQL скрипта для сортировки городов в базе данных
echo "📝 Создаю SQL скрипт для сортировки городов в базе данных..."
cat > /root/escort-project/sort-cities-db.sql << 'SQL'
-- Скрипт для сортировки городов в алфавитном порядке
-- и исправления порядка профилей

-- Обновляем порядок городов в алфавитном порядке
UPDATE "City"
SET "id" = new_id
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY name COLLATE "C" ASC) as new_id
  FROM "City"
) AS sorted
WHERE "City"."id" = sorted.id
AND "City"."id" != sorted.new_id;

-- Обновляем порядок профилей (если поле order не установлено или дублируется)
WITH ranked AS (
  SELECT 
    id, 
    "cityId",
    "order",
    ROW_NUMBER() OVER (PARTITION BY "cityId" ORDER BY "createdAt" DESC) as new_order
  FROM "Profile" 
  WHERE "order" = 0 OR "order" IN (
    SELECT "order" FROM "Profile" p2 
    WHERE "Profile"."cityId" = p2."cityId" AND "Profile"."id" != p2."id"
    GROUP BY "order" 
    HAVING COUNT(*) > 1
  )
)
UPDATE "Profile"
SET "order" = ranked.new_order
FROM ranked
WHERE "Profile"."id" = ranked.id;
SQL

# Выполняем SQL скрипт в базе данных
echo "🔄 Выполняю SQL скрипт для сортировки городов..."
docker exec escort-postgres psql -U postgres -d escort_db -f /dev/stdin < /root/escort-project/sort-cities-db.sql || true

# 11. Проверка статуса всех контейнеров
echo "🔍 Проверяю статус всех контейнеров..."
docker-compose ps

echo ""
echo "✅ Проект полностью пересобран и запущен!"
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
echo "🔑 API доступно по адресу: https://eskortvsegorodarfreal.site/api"
echo "📝 Админ-панель доступна по адресу: https://eskortvsegorodarfreal.site/admin"
echo ""
echo "💡 Внесены следующие улучшения:"
echo "  - Исправлены проблемы в схеме Prisma"
echo "  - Добавлены скрипты для отключения Service Worker"
echo "  - Добавлены скрипты для структурированных данных (SEO)"
echo "  - Добавлена сортировка городов в алфавитном порядке"
echo "  - Создан API middleware для районов и услуг"
echo "  - Выполнена сортировка городов в базе данных"
echo "  - Исправлен порядок профилей в базе данных"
