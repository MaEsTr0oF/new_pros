#!/bin/bash
set -e

echo "🔍 Исправляем Prisma схему"

# Путь к schema.prisma
SCHEMA_PATH="/root/escort-project/server/prisma/schema.prisma"

# Создаем временный файл и удаляем дублирующееся определение поля order
grep -v "order\s*Int\s*@default(0)" $SCHEMA_PATH > ${SCHEMA_PATH}.tmp
mv ${SCHEMA_PATH}.tmp $SCHEMA_PATH

echo "✅ Prisma схема исправлена"
