#!/bin/bash
# Добавляем импорт компонента в начало файла
if ! grep -q "ProfileOrderButtons" /root/escort-project/client/src/pages/admin/ProfilesPage.tsx; then
  sed -i "s/import {/import ProfileOrderButtons from '..\/..\/components\/admin\/ProfileOrderButtons';\nimport {/" /root/escort-project/client/src/pages/admin/ProfilesPage.tsx
  
  # Добавляем кнопки в CardActions
  sed -i "/<\/CardActions>/i \                <ProfileOrderButtons profileId={profile.id} onSuccess={fetchProfiles} onError={setError} \/>" /root/escort-project/client/src/pages/admin/ProfilesPage.tsx
fi
