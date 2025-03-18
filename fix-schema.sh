#!/bin/bash
set -e

echo "🔄 Исправление дублирующегося поля order в схеме Prisma..."
# Создаем временный файл со скорректированной схемой (удаляем дублирующееся поле)
cat /root/escort-project/server/prisma/schema.prisma | awk 'BEGIN{count=0} /order +Int +@default\(0\)/ {count++; if(count>1) next} {print}' > /tmp/schema.prisma
# Заменяем оригинальный файл
cp /tmp/schema.prisma /root/escort-project/server/prisma/schema.prisma

echo "✅ Схема Prisma исправлена"
