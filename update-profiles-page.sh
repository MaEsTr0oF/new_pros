#!/bin/bash

# Добавляем импорт компонента с кнопками
sed -i "s/import {/import ProfileOrderButtons from '..\/..\/components\/admin\/ProfileOrderButtons';\nimport {/" /root/escort-project/client/src/pages/admin/ProfilesPage.tsx

# Добавляем кнопки в список действий с профилем
sed -i "/<\/CardActions>/i \                <ProfileOrderButtons profileId={profile.id} onSuccess={fetchProfiles} onError={setError} \/>" /root/escort-project/client/src/pages/admin/ProfilesPage.tsx
