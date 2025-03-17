import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  // Создаем города - расширенный список 50 городов России
  const cities = [
    { name: 'Москва' },
    { name: 'Санкт-Петербург' },
    { name: 'Новосибирск' },
    { name: 'Екатеринбург' },
    { name: 'Казань' },
    { name: 'Нижний Новгород' },
    { name: 'Челябинск' },
    { name: 'Омск' },
    { name: 'Самара' },
    { name: 'Ростов-на-Дону' },
    { name: 'Уфа' },
    { name: 'Красноярск' },
    { name: 'Пермь' },
    { name: 'Воронеж' },
    { name: 'Волгоград' },
    { name: 'Краснодар' },
    { name: 'Саратов' },
    { name: 'Тюмень' },
    { name: 'Тольятти' },
    { name: 'Ижевск' },
    { name: 'Барнаул' },
    { name: 'Ульяновск' },
    { name: 'Иркутск' },
    { name: 'Хабаровск' },
    { name: 'Ярославль' },
    { name: 'Владивосток' },
    { name: 'Махачкала' },
    { name: 'Томск' },
    { name: 'Оренбург' },
    { name: 'Кемерово' },
    { name: 'Новокузнецк' },
    { name: 'Рязань' },
    { name: 'Астрахань' },
    { name: 'Набережные Челны' },
    { name: 'Пенза' },
    { name: 'Липецк' },
    { name: 'Киров' },
    { name: 'Чебоксары' },
    { name: 'Калининград' },
    { name: 'Тула' },
    { name: 'Сочи' },
    { name: 'Ставрополь' },
    { name: 'Севастополь' },
    { name: 'Улан-Удэ' },
    { name: 'Тверь' },
    { name: 'Магнитогорск' },
    { name: 'Иваново' },
    { name: 'Брянск' },
    { name: 'Белгород' },
    { name: 'Сургут' }
  ];

  // Очищаем существующие города перед добавлением новых
  // для избежания конфликтов с уникальными именами
  console.log('Очистка существующих городов...');
  try {
    // Удаляем все связанные профили
    await prisma.profile.deleteMany({});
    // Теперь можно безопасно удалить города
    await prisma.city.deleteMany({});
    console.log('Существующие города успешно удалены');
  } catch (error) {
    console.error('Ошибка при очистке существующих городов:', error);
  }

  // Создаем города
  console.log('Добавление новых городов...');
  for (const city of cities) {
    await prisma.city.create({
      data: city
    });
  }
  console.log(`Добавлено ${cities.length} городов`);

  // Проверяем существование админа перед созданием
  const adminExists = await prisma.admin.findUnique({
    where: {
      username: 'admin'
    }
  });

  if (!adminExists) {
    console.log('Создание администратора...');
    // Создаем администратора с более надежным паролем
    const hashedPassword = await bcrypt.hash('admin123', 10);
    await prisma.admin.create({
      data: {
        username: 'admin',
        password: hashedPassword
      }
    });
    console.log('Администратор успешно создан');
  } else {
    console.log('Администратор уже существует, пропускаем создание');
  }

  // Создаем настройки сайта, если их еще нет
  const settingsExist = await prisma.settings.findFirst();
  if (!settingsExist) {
    console.log('Создание настроек сайта...');
    await prisma.settings.create({
      data: {
        telegramUsername: "escort_admin",
        notificationsEnabled: true,
        autoModeration: false,
        defaultCity: "Москва",
        maintenanceMode: false,
        watermarkEnabled: true,
        watermarkText: "@escort_service",
        minPhotoCount: 3,
        maxPhotoCount: 10,
        defaultPriceHour: 5000,
        defaultPriceTwoHours: 10000,
        defaultPriceNight: 30000
      }
    });
    console.log('Настройки сайта успешно созданы');
  }

  console.log('База данных успешно заполнена начальными данными');
}

main()
  .catch((e) => {
    console.error('Ошибка при заполнении базы данных:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  }); 