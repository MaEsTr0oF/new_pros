const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function addCity() {
  try {
    // Из ошибки видно, что поле code не существует
    const city = await prisma.city.create({
      data: {
        name: 'Москва'
        // поле code не существует в модели City
      }
    });
    
    console.log('Город успешно создан:', city);
  } catch (error) {
    console.error('Ошибка при создании города:', error);
  } finally {
    await prisma.$disconnect();
  }
}

addCity();
