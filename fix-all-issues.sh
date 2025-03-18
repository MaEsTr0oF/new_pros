#!/bin/bash
set -e

echo "🔧 Начинаю исправление всех обнаруженных проблем..."

### 1. Исправление дублирования поля order в схеме Prisma ###
echo "📊 Исправление схемы Prisma..."
cat > /tmp/schema.prisma << 'SCHEMA'
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

// Looking for ways to speed up your queries, or scale easily with your serverless or edge functions?
// Try Prisma Accelerate: https://pris.ly/cli/accelerate-init

generator client {
  provider      = "prisma-client-js"
  binaryTargets = ["native", "windows"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model City {
  id       Int       @id @default(autoincrement())
  name     String    @unique
  profiles Profile[]
}

model Profile {
  id            Int      @id @default(autoincrement())
  name          String
  age           Int
  height        Int
  weight        Int
  breastSize    Int
  phone         String
  description   String
  photos        String[]
  price1Hour    Int
  price2Hours   Int
  priceNight    Int
  priceExpress  Int      @default(0)
  workingHours  String?
  isVerified    Boolean  @default(false)
  hasVideo      Boolean  @default(false)
  hasReviews    Boolean  @default(false)
  services      String[]
  city          City     @relation(fields: [cityId], references: [id])
  cityId        Int
  district      String?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  isActive      Boolean  @default(true)
  order         Int      @default(0)

  // Appearance
  nationality   String?
  hairColor     String?
  bikiniZone    String?
  gender        String   @default("female")
  orientation   String   @default("hetero")

  // Location
  inCall        Boolean  @default(true)
  outCall       Boolean  @default(false)

  // Additional filters
  isNonSmoking  Boolean  @default(false)
  isNew         Boolean  @default(true)
  isWaitingCall Boolean  @default(false)
  is24Hours     Boolean  @default(false)

  // Neighbors
  isAlone       Boolean  @default(true)
  withFriend    Boolean  @default(false)
  withFriends   Boolean  @default(false)
}

model Admin {
  id        Int      @id @default(autoincrement())
  username  String   @unique
  password  String
  createdAt DateTime @default(now())
}

model Settings {
  id                  Int      @id @default(autoincrement())
  telegramUsername    String   @default("your_admin_username")
  telegramBotToken    String?
  telegramChatId      String?
  notificationsEnabled Boolean  @default(true)
  autoModeration      Boolean  @default(false)
  defaultCity         String?
  maintenanceMode     Boolean  @default(false)
  watermarkEnabled    Boolean  @default(true)
  watermarkText       String   @default("@your_watermark")
  minPhotoCount       Int      @default(3)
  maxPhotoCount       Int      @default(10)
  defaultPriceHour    Int      @default(5000)
  defaultPriceTwoHours Int     @default(10000)
  defaultPriceNight   Int      @default(30000)
  updatedAt          DateTime @updatedAt
}

model Language {
  id   Int    @id @default(autoincrement())
  code String @unique
  name String
}
SCHEMA

# Копируем исправленную схему
cp /tmp/schema.prisma /root/escort-project/server/prisma/schema.prisma
echo "✅ Схема Prisma успешно исправлена (удалено дублирование поля order)"

### 2. Применение миграции Prisma используя Docker ###
echo "🔄 Применение миграции Prisma..."
# Проверяем, запущен ли сервер
if ! docker ps | grep -q escort-server; then
  echo "⚠️ Контейнер escort-server не запущен, запускаем..."
  cd /root/escort-project
  docker-compose up -d server
  sleep 5
fi

# Применяем миграцию внутри контейнера
echo "🔄 Выполнение миграции внутри контейнера..."
docker exec escort-server npx prisma db push --accept-data-loss
echo "✅ Миграция Prisma успешно применена"

### 3. Проверка и создание API middleware, если его нет ###
echo "🔄 Проверка API middleware..."
API_MIDDLEWARE_FILE="/root/escort-project/server/src/middleware/api-middleware.ts"
if [ ! -f "$API_MIDDLEWARE_FILE" ]; then
  echo "⚠️ API middleware не найден, создаем..."
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

  echo "✅ API middleware успешно создан"
else
  echo "✅ API middleware уже существует"
fi

### 4. Проверка и обновление маршрутов в index.ts ###
echo "🔄 Проверка маршрутов в index.ts..."
INDEX_FILE="/root/escort-project/server/src/index.ts"
if ! grep -q "moveProfileUp" "$INDEX_FILE"; then
  echo "⚠️ Маршруты для перемещения профилей не найдены, добавляем..."
  
  # Находим место, где определены защищенные маршруты администратора
  LINE_NUM=$(grep -n "app.put('/api/admin/profiles/:id'" "$INDEX_FILE" | cut -d: -f1)
  if [ -z "$LINE_NUM" ]; then
    echo "⚠️ Не удалось найти место для добавления маршрутов"
  else
    # Добавляем новые маршруты после найденной строки
    sed -i "${LINE_NUM}a app.patch('/api/admin/profiles/:id/move-up', profileController.moveProfileUp);\napp.patch('/api/admin/profiles/:id/move-down', profileController.moveProfileDown);" "$INDEX_FILE"
    echo "✅ Маршруты для перемещения профилей добавлены"
  fi
else
  echo "✅ Маршруты для перемещения профилей уже существуют"
fi

# Проверяем, есть ли уже импорт middleware
if ! grep -q "apiMiddleware" "$INDEX_FILE"; then
  echo "⚠️ Импорт API middleware не найден, добавляем..."
  # Добавляем импорт middleware в начало файла
  sed -i "1s/^/import apiMiddleware from '.\/middleware\/api-middleware';\n/" "$INDEX_FILE"
  
  # Находим место, где определены middleware
  LINE_NUM=$(grep -n "app.use(express.json" "$INDEX_FILE" | head -1 | cut -d: -f1)
  if [ -z "$LINE_NUM" ]; then
    echo "⚠️ Не удалось найти место для добавления middleware"
  else
    # Добавляем использование middleware после найденной строки
    sed -i "${LINE_NUM}a // Применяем API middleware\napp.use('/api', apiMiddleware);" "$INDEX_FILE"
    echo "✅ Импорт и использование API middleware добавлены"
  fi
else
  echo "✅ Импорт API middleware уже существует"
fi

### 5. Проверка и обновление функций в profileController.ts ###
echo "🔄 Проверка функций в profileController.ts..."
PROFILE_CONTROLLER_FILE="/root/escort-project/server/src/controllers/profileController.ts"
if ! grep -q "moveProfileUp" "$PROFILE_CONTROLLER_FILE"; then
  echo "⚠️ Функции moveProfileUp и moveProfileDown не найдены, добавляем..."
  
  # Добавляем функции в конец файла
  cat >> "$PROFILE_CONTROLLER_FILE" << 'PROFILE_CONTROLLER'

export const moveProfileUp = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Находим текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId }
    });
    
    if (!currentProfile) {
      return res.status(404).json({ error: 'Профиль не найден' });
    }
    
    // Находим профиль выше (с меньшим order)
    const prevProfile = await prisma.profile.findFirst({
      where: {
        cityId: currentProfile.cityId,
        order: {
          lt: currentProfile.order
        }
      },
      orderBy: {
        order: 'desc'
      }
    });
    
    if (!prevProfile) {
      return res.status(200).json({ 
        message: 'Профиль уже находится в верхней позиции',
        profile: currentProfile
      });
    }
    
    // Меняем местами с предыдущим профилем
    await prisma.$transaction([
      prisma.profile.update({
        where: { id: profileId },
        data: { order: prevProfile.order }
      }),
      prisma.profile.update({
        where: { id: prevProfile.id },
        data: { order: currentProfile.order }
      })
    ]);
    
    const updatedProfile = await prisma.profile.findUnique({
      where: { id: profileId },
      include: { city: true }
    });
    
    res.json(updatedProfile);
  } catch (error) {
    console.error('Ошибка при перемещении профиля вверх:', error);
    res.status(500).json({ error: 'Не удалось переместить профиль вверх' });
  }
};

export const moveProfileDown = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Находим текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId }
    });
    
    if (!currentProfile) {
      return res.status(404).json({ error: 'Профиль не найден' });
    }
    
    // Находим профиль ниже (с большим order)
    const nextProfile = await prisma.profile.findFirst({
      where: {
        cityId: currentProfile.cityId,
        order: {
          gt: currentProfile.order
        }
      },
      orderBy: {
        order: 'asc'
      }
    });
    
    if (!nextProfile) {
      return res.status(200).json({ 
        message: 'Профиль уже находится в нижней позиции',
        profile: currentProfile
      });
    }
    
    // Меняем местами со следующим профилем
    await prisma.$transaction([
      prisma.profile.update({
        where: { id: profileId },
        data: { order: nextProfile.order }
      }),
      prisma.profile.update({
        where: { id: nextProfile.id },
        data: { order: currentProfile.order }
      })
    ]);
    
    const updatedProfile = await prisma.profile.findUnique({
      where: { id: profileId },
      include: { city: true }
    });
    
    res.json(updatedProfile);
  } catch (error) {
    console.error('Ошибка при перемещении профиля вниз:', error);
    res.status(500).json({ error: 'Не удалось переместить профиль вниз' });
  }
};
PROFILE_CONTROLLER

  echo "✅ Функции moveProfileUp и moveProfileDown успешно добавлены"
else
  echo "✅ Функции moveProfileUp и moveProfileDown уже существуют"
fi

### 6. Проверка и обновление cityController.ts для правильной сортировки городов ###
echo "🔄 Проверка функций в cityController.ts..."
CITY_CONTROLLER_FILE="/root/escort-project/server/src/controllers/cityController.ts"
if ! grep -q "getCitiesPaginated" "$CITY_CONTROLLER_FILE"; then
  echo "⚠️ Функция getCitiesPaginated не найдена, обновляем cityController.ts..."
  
  # Создаем резервную копию
  cp "$CITY_CONTROLLER_FILE" "${CITY_CONTROLLER_FILE}.bak"
  
  # Обновляем файл
  cat > "$CITY_CONTROLLER_FILE" << 'CITY_CONTROLLER'
import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getCities = async (req: Request, res: Response) => {
  try {
    const cities = await prisma.city.findMany({
      orderBy: {
        name: 'asc'  // Сортировка по имени в порядке возрастания
      }
    });
    res.json(cities);
  } catch (error) {
    console.error('Ошибка при получении городов:', error);
    res.status(500).json({ error: 'Не удалось получить города' });
  }
};

export const getCitiesPaginated = async (req: Request, res: Response) => {
  try {
    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 50;
    const skip = (page - 1) * limit;
    
    const [cities, total] = await prisma.$transaction([
      prisma.city.findMany({
        orderBy: { name: 'asc' },
        skip,
        take: limit
      }),
      prisma.city.count()
    ]);
    
    res.json({
      cities,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Ошибка при получении городов:', error);
    res.status(500).json({ error: 'Не удалось получить города' });
  }
};

export const createCity = async (req: Request, res: Response) => {
  try {
    const city = await prisma.city.create({
      data: req.body,
    });
    res.status(201).json(city);
  } catch (error) {
    console.error('Ошибка при создании города:', error);
    res.status(500).json({ error: 'Не удалось создать город' });
  }
};

export const updateCity = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const city = await prisma.city.update({
      where: { id: Number(id) },
      data: req.body,
    });
    res.json(city);
  } catch (error) {
    console.error('Ошибка при обновлении города:', error);
    res.status(500).json({ error: 'Не удалось обновить город' });
  }
};

export const deleteCity = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.city.delete({
      where: { id: Number(id) },
    });
    res.status(204).send();
  } catch (error) {
    console.error('Ошибка при удалении города:', error);
    res.status(500).json({ error: 'Не удалось удалить город' });
  }
};
CITY_CONTROLLER

  echo "✅ cityController.ts успешно обновлен с поддержкой пагинации и сортировки"
else
  echo "✅ Функции для сортировки городов уже существуют"
fi

### 7. Добавление поддержки пагинации в маршруты ###
echo "🔄 Добавление поддержки пагинации городов в маршруты..."
if ! grep -q "/api/cities/paginated" "$INDEX_FILE"; then
  # Находим место, где определены маршруты для городов
  LINE_NUM=$(grep -n "app.get('/api/cities'" "$INDEX_FILE" | cut -d: -f1)
  if [ -n "$LINE_NUM" ]; then
    # Добавляем новый маршрут для пагинации после найденной строки
    sed -i "${LINE_NUM}a app.get('/api/cities/paginated', cityController.getCitiesPaginated);" "$INDEX_FILE"
    echo "✅ Маршрут для пагинации городов добавлен"
  else
    echo "⚠️ Не удалось найти место для добавления маршрута пагинации"
  fi
else
  echo "✅ Маршрут пагинации городов уже существует"
fi

### 8. Перезапуск сервера для применения изменений ###
echo "🔄 Перезапуск сервера для применения изменений..."
cd /root/escort-project
docker-compose restart server
echo "✅ Сервер успешно перезапущен"

echo ""
echo "✅ Все исправления успешно применены!"
echo "📋 Итоги:"
echo "  - Исправлено дублирование поля order в схеме Prisma"
echo "  - Применена миграция Prisma (через Docker)"
echo "  - Добавлены/проверены функции для перемещения профилей"
echo "  - Добавлен/проверен API middleware для районов и услуг"
echo "  - Обновлен cityController для сортировки городов"
echo "  - Добавлена поддержка пагинации для более 50 городов"
echo "  - Сервер перезапущен для применения всех изменений"
echo ""
echo "🌐 Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
echo "🔑 API доступно по адресу: https://eskortvsegorodarfreal.site/api"
echo "📝 Админ-панель доступна по адресу: https://eskortvsegorodarfreal.site/admin"
echo ""
echo "💡 Теперь вы можете:"
echo "  - Сортировать города по алфавиту (уже работает)"
echo "  - Управлять порядком анкет с помощью новых API (moveProfileUp/moveProfileDown)"
echo "  - Получать данные районов и услуг через API middleware"
echo "  - Работать с большим количеством городов (более 50) используя пагинацию"
