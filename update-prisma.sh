#!/bin/bash
# Проверяем, есть ли уже поле order в модели Profile
if grep -q "order\s*Int\s*@default(0)" /root/escort-project/server/prisma/schema.prisma; then
  echo "Поле order уже существует в схеме"
else
  # Добавляем поле order в модель Profile
  sed -i '/model Profile {/,/}/{s/}/  order       Int      @default(0)\n}/}' /root/escort-project/server/prisma/schema.prisma
  echo "Поле order добавлено в схему"
fi
