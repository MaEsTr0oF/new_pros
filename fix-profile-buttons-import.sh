#!/bin/bash

echo "🔧 Исправление импорта ProfileOrderButtons в CitiesPage.tsx..."

# Создаем резервную копию файла
cp /root/escort-project/client/src/pages/admin/CitiesPage.tsx /root/escort-project/client/src/pages/admin/CitiesPage.tsx.bak2

# Проверяем наличие импорта ProfileOrderButtons
if ! grep -q "import ProfileOrderButtons" /root/escort-project/client/src/pages/admin/CitiesPage.tsx; then
  # Добавляем импорт в начало файла после других импортов
  sed -i '1,/^import/s/\(^import.*;\)/\1\nimport ProfileOrderButtons from "../components\/admin\/ProfileOrderButtons";/' /root/escort-project/client/src/pages/admin/CitiesPage.tsx
fi

# Исправляем дублирующиеся ProfileOrderButtons
sed -i 's/<ProfileOrderButtons profileId={profile.id} \/>.*<ProfileOrderButtons profileId={profile.id} \/>/                  <ProfileOrderButtons profileId={profile.id} \/>/' /root/escort-project/client/src/pages/admin/CitiesPage.tsx

echo "✅ Импорт ProfileOrderButtons исправлен!"
