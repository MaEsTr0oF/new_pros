const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function resetAdmin() {
  try {
    // Удаляем текущего админа (если есть)
    await prisma.admin.deleteMany({
      where: { username: "admin" }
    });
    
    // Создаем нового админа
    await prisma.admin.create({
      data: {
        username: "admin",
        password: "$2a$10$K.0HwpsoPDGaB/atFBmmXOGTw4ceeg33.WXgRWQP4hRj0IXIWEkyG" // admin123
      }
    });
    
    console.log("Администратор успешно пересоздан");
  } catch (error) {
    console.error("Ошибка при сбросе администратора:", error);
  } finally {
    await prisma.$disconnect();
  }
}

resetAdmin();
