#!/bin/bash
set -e

echo "🔄 Выполнение миграции Prisma внутри контейнера..."
# Запускаем миграцию внутри Docker-контейнера
docker exec escort-server npx prisma migrate dev --name fix_profile_order --create-only
docker exec escort-server npx prisma db push

echo "✅ Миграция Prisma выполнена"
