#!/bin/bash
set -e

echo "🔧 Начинаем исправление проекта..."

# 1. Создаем все необходимые директории
echo "📁 Создаем необходимые директории..."
mkdir -p /root/escort-project/server/src/middleware
mkdir -p /root/escort-project/client/public

# 2. Проверяем наличие необходимых пакетов в серверной части
echo "📦 Проверяем зависимости сервера..."
cd /root/escort-project/server

if [ ! -f "package.json" ]; then
  echo "❌ Ошибка: Файл package.json не найден в директории сервера"
  exit 1
fi

# Устанавливаем зависимости для сервера
echo "📦 Устанавливаем зависимости сервера..."
npm install

# Устанавливаем Prisma CLI
echo "📦 Устанавливаем Prisma CLI..."
npm install --save-dev prisma

# 3. Останавливаем контейнеры
echo "🛑 Останавливаем контейнеры..."
cd /root/escort-project
docker-compose down

# 4. Обновляем Prisma схему
echo "📝 Обновляем Prisma схему..."
bash /root/escort-project/update-prisma-schema.sh

# 5. Создаем и обновляем необходимые файлы
# ... [здесь остальной код скрипта] ...

# Запускаем контейнеры
echo "🚀 Запускаем контейнеры..."
docker-compose up -d

# Сообщение об успешном завершении
echo "✅ Все исправления успешно применены!"
echo "�� Сайт доступен по адресу: https://eskortvsegorodarfreal.site"
