#!/bin/bash
set -e

echo "🔄 Исправляем схему Prisma, добавляя поле order в модель Profile"

# Путь к schema.prisma
SCHEMA_PATH="/root/escort-project/server/prisma/schema.prisma"

# Создаем резервную копию
cp $SCHEMA_PATH ${SCHEMA_PATH}.bak2

# Ищем строку с объявлением модели Profile
PROFILE_LINE=$(grep -n "model Profile {" $SCHEMA_PATH | cut -d: -f1)

# Проверяем, есть ли уже поле order
if ! grep -q "order\s*Int" $SCHEMA_PATH; then
  # Добавляем поле order после строки с моделью Profile
  sed -i "$((PROFILE_LINE+1)) i \  order         Int      @default(0)" $SCHEMA_PATH
  echo "✅ Поле order добавлено в модель Profile"
else
  echo "⚠️ Поле order уже существует в модели Profile"
fi

echo "✅ Схема Prisma обновлена"
