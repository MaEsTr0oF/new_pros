#!/bin/bash
set -e

echo "🔧 Исправляем DashboardPage.tsx для использования правильного API"

# Путь к файлу
DASHBOARD_PATH="/root/escort-project/client/src/pages/admin/DashboardPage.tsx"

# Создаем резервную копию
cp $DASHBOARD_PATH ${DASHBOARD_PATH}.bak

# Находим и исправляем неправильное использование API
sed -i 's/const response = await api.get(.admin.profiles.);/const response = await api.profiles.getAll();/g' $DASHBOARD_PATH

echo "✅ DashboardPage.tsx исправлен"
