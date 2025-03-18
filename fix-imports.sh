#!/bin/bash
set -e

echo "🔧 Исправляем дублирующийся импорт в ProfilesPage.tsx"

# Путь к файлу
PROFILES_PAGE_PATH="/root/escort-project/client/src/pages/admin/ProfilesPage.tsx"

# Создаем резервную копию
cp $PROFILES_PAGE_PATH ${PROFILES_PAGE_PATH}.bak

# Исправляем дублирующийся импорт
sed -i '/import ProfileOrderButtons/d' $PROFILES_PAGE_PATH
sed -i '2i import ProfileOrderButtons from "../../components/admin/ProfileOrderButtons";' $PROFILES_PAGE_PATH

echo "✅ Импорт в ProfilesPage.tsx исправлен"
