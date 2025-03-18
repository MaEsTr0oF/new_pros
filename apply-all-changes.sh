#!/bin/bash
set -e

echo "🚀 Применение всех изменений..."

# 1. Обновление Prisma схемы
echo "�� Обновление Prisma схемы..."
/root/escort-project/update-prisma.sh

# 2. Обновление контроллеров
echo "📝 Обновление контроллеров..."
/root/escort-project/update-city-controller.sh
/root/escort-project/update-profile-controller.sh

# 3. Создание middleware
echo "📝 Создание API middleware..."
/root/escort-project/create-middleware.sh

# 4. Обновление маршрутов
echo "📝 Обновление маршрутов..."
/root/escort-project/update-routes.sh

# 5. Выполнение миграции Prisma
echo "📝 Применение миграции Prisma..."
/root/escort-project/create-migration.sh

# 6. Перезапуск приложения
echo "🔄 Перезапуск приложения..."
cd /root/escort-project
docker-compose restart server

echo "✅ Все изменения успешно применены!"
