const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function addTestCity() {
  try {
    const newCity = await prisma.city.create({
      data: {
        name: "Москва",
        code: "moscow"
      }
    });
    console.log("Тестовый город добавлен:", newCity);
  } catch (error) {
    console.error("Ошибка при добавлении города:", error);
  } finally {
    await prisma.$disconnect();
  }
}

addTestCity();
