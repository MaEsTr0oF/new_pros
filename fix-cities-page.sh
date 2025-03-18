#!/bin/bash

echo "🔧 Исправление CitiesPage.tsx..."

# Создаем резервную копию файла
cp /root/escort-project/client/src/pages/admin/CitiesPage.tsx /root/escort-project/client/src/pages/admin/CitiesPage.tsx.bak

# Удаляем некорректные вставки с помощью awk
awk '
  /{profile <\/IconButton><\/IconButton> <ProfileOrderButtons profileId={profile\.id} \/>}/ {
    gsub(/{profile <\/IconButton><\/IconButton> <ProfileOrderButtons profileId={profile\.id} \/>}/, "<ProfileOrderButtons profileId={profile.id} />");
  }
  {print}
' /root/escort-project/client/src/pages/admin/CitiesPage.tsx.bak > /root/escort-project/client/src/pages/admin/CitiesPage.tsx

echo "✅ CitiesPage.tsx исправлен!"
