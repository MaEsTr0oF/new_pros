#!/bin/bash
# Проверяем, есть ли поле order в схеме
if ! grep -q "order" /root/escort-project/server/prisma/schema.prisma; then
  # Добавляем поле order в модель Profile перед строкой с // Appearance
  sed -i '/\/\/ Appearance/i \  order         Int      @default(0)' /root/escort-project/server/prisma/schema.prisma
fi
