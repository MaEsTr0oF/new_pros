#!/bin/bash
cd /root/escort-project/server

# Создаем миграцию
npx prisma migrate dev --name add_profile_order

echo "Миграция создана и применена"
