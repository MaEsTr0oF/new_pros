import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';
import * as profileController from './controllers/profileController';
import * as cityController from './controllers/cityController';
import * as authController from './controllers/authController';
import * as settingsController from './controllers/settingsController';
import { authMiddleware } from './middleware/auth';

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
app.patch("/api/admin/profiles/:id/moveUp", profileController.moveProfileUp);
app.patch("/api/admin/profiles/:id/moveDown", profileController.moveProfileDown);
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