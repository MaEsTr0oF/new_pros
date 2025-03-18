const { PrismaClient } = require('@prisma/client');
const slugify = require('slugify');

const prisma = new PrismaClient();

/**
 * Миграция данных из старой структуры (cityId в Profile) в новую (ProfilesOnCities)
 */
async function migrateCityData() {
  try {
    console.log('🚀 Начинаем миграцию связей профилей с городами...');

    // Получаем все профили
    const profiles = await prisma.profile.findMany();
    console.log(`📊 Найдено ${profiles.length} профилей`);

    // Для каждого профиля создаем связь с его cityId
    let success = 0;
    let failed = 0;

    for (const profile of profiles) {
      try {
        // Проверяем, существует ли город с таким cityId
        if (!profile.cityId) {
          console.log(`⚠️ Профиль ${profile.id} не имеет cityId, пропускаем`);
          continue;
        }

        const city = await prisma.city.findUnique({
          where: { id: profile.cityId }
        });

        if (!city) {
          console.log(`⚠️ Для профиля ${profile.id} не найден город с id=${profile.cityId}`);
          continue;
        }

        // Проверяем, существует ли уже связь
        const existingLink = await prisma.$queryRaw`
          SELECT * FROM "ProfilesOnCities" 
          WHERE "profileId" = ${profile.id} AND "cityId" = ${profile.cityId}
        `;

        if (existingLink && existingLink.length > 0) {
          console.log(`ℹ️ Связь между профилем ${profile.id} и городом ${profile.cityId} уже существует`);
          success++;
          continue;
        }

        // Создаем связь через сырой SQL запрос
        await prisma.$executeRaw`
          INSERT INTO "ProfilesOnCities" ("profileId", "cityId")
          VALUES (${profile.id}, ${profile.cityId})
        `;

        console.log(`✅ Создана связь между профилем ${profile.id} и городом ${profile.cityId}`);
        success++;
      } catch (error) {
        console.error(`❌ Ошибка при обработке профиля ${profile.id}:`, error);
        failed++;
      }
    }

    console.log(`✅ Миграция завершена: успешно - ${success}, ошибок - ${failed}`);
    return { success, failed };
  } catch (error) {
    console.error('❌ Ошибка при миграции связей профилей с городами:', error);
    throw error;
  }
}

/**
 * Сортировка городов по алфавиту
 */
async function sortCitiesByAlphabet() {
  try {
    console.log('🚀 Начинаем сортировку городов по алфавиту...');

    // Получаем все города, отсортированные по имени
    const cities = await prisma.city.findMany({
      orderBy: { name: 'asc' }
    });

    console.log(`📊 Найдено ${cities.length} городов для сортировки`);

    // Обновляем приоритеты городов в соответствии с их позицией в отсортированном массиве
    let success = 0;
    let failed = 0;

    for (let i = 0; i < cities.length; i++) {
      try {
        await prisma.$executeRaw`
          UPDATE "City" 
          SET priority = ${i + 1}
          WHERE id = ${cities[i].id}
        `;
        console.log(`✅ Установлен приоритет ${i + 1} для города ${cities[i].name}`);
        success++;
      } catch (error) {
        console.error(`❌ Ошибка при обновлении приоритета для города ${cities[i].name}:`, error);
        failed++;
      }
    }

    console.log(`✅ Сортировка завершена: успешно - ${success}, ошибок - ${failed}`);
    return { success, failed };
  } catch (error) {
    console.error('❌ Ошибка при сортировке городов:', error);
    throw error;
  }
}

// Функция для добавления полей slug и priority для городов
async function updateCitySchema() {
  try {
    console.log('🚀 Начинаем обновление схемы для городов...');

    // Проверяем, есть ли поле slug в таблице City
    let hasSlugField = false;
    let hasPriorityField = false;
    
    try {
      // Пробуем выполнить запрос, который проверит наличие полей
      await prisma.$queryRaw`SELECT slug FROM "City" LIMIT 1`;
      hasSlugField = true;
      console.log('✅ Поле slug уже существует в таблице City');
    } catch (error) {
      console.log('❌ Поле slug отсутствует в таблице City, требуется миграция');
    }
    
    try {
      await prisma.$queryRaw`SELECT priority FROM "City" LIMIT 1`;
      hasPriorityField = true;
      console.log('✅ Поле priority уже существует в таблице City');
    } catch (error) {
      console.log('❌ Поле priority отсутствует в таблице City, требуется миграция');
    }
    
    // Если обоих полей нет, добавляем их
    if (!hasSlugField || !hasPriorityField) {
      console.log('🔄 Применяем миграцию для добавления необходимых полей...');
      
      if (!hasSlugField) {
        // Добавляем поле slug
        await prisma.$executeRaw`ALTER TABLE "City" ADD COLUMN slug TEXT`;
        console.log('✅ Поле slug добавлено в таблицу City');
      }
      
      if (!hasPriorityField) {
        // Добавляем поле priority
        await prisma.$executeRaw`ALTER TABLE "City" ADD COLUMN priority INTEGER DEFAULT 9999`;
        console.log('✅ Поле priority добавлено в таблицу City');
      }
      
      // Создаем slug для каждого города
      if (!hasSlugField) {
        await generateCitySlugs();
      }
      
      // После добавления полей, делаем slug уникальным
      if (!hasSlugField) {
        await prisma.$executeRaw`ALTER TABLE "City" ALTER COLUMN slug SET NOT NULL`;
        await prisma.$executeRaw`CREATE UNIQUE INDEX "City_slug_key" ON "City"(slug)`;
        console.log('✅ Создан уникальный индекс для поля slug');
      }
    }
    
    return { hasSlugField, hasPriorityField };
  } catch (error) {
    console.error('❌ Ошибка при обновлении схемы для городов:', error);
    throw error;
  }
}

async function main() {
  try {
    console.log('📝 Начинаем процесс миграции данных...');

    // Шаг 1: Проверяем и обновляем схему для города
    await updateCitySchema();
    
    // Шаг 2: Миграция cityId -> cities
    await migrateCityData();

    // Шаг 3: Сортируем города по алфавиту
    await sortCitiesByAlphabet();

    console.log('✅ Миграция данных успешно завершена!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Ошибка при миграции данных:', error);
    process.exit(1);
  }
}

main(); 