#!/bin/bash
set -e

echo "🔍 Анализирую структуру интерфейса..."

# Определяем основные файлы интерфейса
find /root/escort-project/client/src -type f -name "*.tsx" -o -name "*.jsx" | xargs grep -l "Панель управления" > /tmp/admin_components.txt

echo "📄 Найденные компоненты интерфейса:"
cat /tmp/admin_components.txt

# Находим компонент анкет
ANKETS_COMPONENT=$(find /root/escort-project/client/src -type f -name "*.tsx" -o -name "*.jsx" | xargs grep -l "Анкеты" | head -1)
echo "✅ Компонент анкет: $ANKETS_COMPONENT"

# Находим компонент для редактирования с кнопками
ACTIONS_COMPONENT=$(find /root/escort-project/client/src -type f -name "*.tsx" -o -name "*.jsx" | xargs grep -l "EditIcon\|редактировать\|удалить" | head -1)
echo "✅ Компонент действий: $ACTIONS_COMPONENT"

# Создаем компонент кнопок порядка, если его нет
BUTTONS_COMPONENT="/root/escort-project/client/src/components/admin/ProfileOrderButtons.tsx"
mkdir -p "/root/escort-project/client/src/components/admin"

echo "🔧 Обновляю компонент кнопок порядка..."
cat > "$BUTTONS_COMPONENT" << 'END'
import React from 'react';
import { IconButton, Tooltip } from '@mui/material';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownward';
import { api } from '../../api';

interface ProfileOrderButtonsProps {
  profileId: number;
  onSuccess?: () => void;
}

const ProfileOrderButtons: React.FC<ProfileOrderButtonsProps> = ({ profileId, onSuccess }) => {
  const handleMoveUp = async () => {
    try {
      console.log("Перемещение профиля вверх:", profileId);
      await api.patch(`/api/admin/profiles/${profileId}/moveUp`);
      console.log("Профиль успешно перемещен вверх");
      if (onSuccess) onSuccess();
      else window.location.reload();
    } catch (error) {
      console.error('Ошибка при перемещении профиля вверх:', error);
      alert('Ошибка при перемещении профиля вверх');
    }
  };

  const handleMoveDown = async () => {
    try {
      console.log("Перемещение профиля вниз:", profileId);
      await api.patch(`/api/admin/profiles/${profileId}/moveDown`);
      console.log("Профиль успешно перемещен вниз");
      if (onSuccess) onSuccess();
      else window.location.reload();
    } catch (error) {
      console.error('Ошибка при перемещении профиля вниз:', error);
      alert('Ошибка при перемещении профиля вниз');
    }
  };

  return (
    <>
      <Tooltip title="Переместить выше">
        <IconButton
          size="small"
          color="primary"
          onClick={handleMoveUp}
          aria-label="переместить вверх"
          style={{ marginLeft: '5px' }}
        >
          <ArrowUpwardIcon />
        </IconButton>
      </Tooltip>
      <Tooltip title="Переместить ниже">
        <IconButton
          size="small"
          color="primary"
          onClick={handleMoveDown}
          aria-label="переместить вниз"
        >
          <ArrowDownwardIcon />
        </IconButton>
      </Tooltip>
    </>
  );
};

export default ProfileOrderButtons;
END
echo "✅ Компонент кнопок порядка обновлен"

# Добавляем кнопки напрямую в интерфейс
echo "🔧 Добавляю кнопки в компонент действий..."

# Находим все файлы, связанные с отображением редактирования анкет
PROFILE_COMPONENTS=$(find /root/escort-project/client/src -type f -name "*.tsx" -o -name "*.jsx" | xargs grep -l "редактировать\|EditIcon\|DeleteIcon\|удалить\|profile\.id" | grep -v "ProfileOrderButtons")

for component in $PROFILE_COMPONENTS; do
  echo "📄 Проверяю компонент: $component"
  cp "$component" "${component}.bak_restore"
  
  # Добавляем импорт, если его нет
  if ! grep -q "import ProfileOrderButtons" "$component"; then
    sed -i '1s/^/import ProfileOrderButtons from "..\/components\/admin\/ProfileOrderButtons";\n/' "$component"
    echo "✅ Добавлен импорт ProfileOrderButtons в $component"
  fi
  
  # Ищем место для добавления кнопок (рядом с кнопками редактирования/удаления)
  if grep -q "EditIcon\|DeleteIcon\|редактировать\|удалить" "$component"; then
    # Используем sed для добавления компонента кнопок после кнопок действий
    sed -i 's/<\/IconButton>/<\/IconButton>\n              <ProfileOrderButtons profileId={profile.id} \/>/' "$component"
    echo "✅ Добавлены кнопки порядка в $component"
  fi
done

# Проверяем основной файл маршрутизации, чтобы убедиться, что старый интерфейс доступен
APP_ROUTER="/root/escort-project/client/src/App.tsx"
if [ -f "$APP_ROUTER" ]; then
  cp "$APP_ROUTER" "${APP_ROUTER}.bak_router"
  
  # Проверяем маршруты к старому интерфейсу
  if grep -q "/admin/profiles" "$APP_ROUTER" && ! grep -q "/admin/profiles/management" "$APP_ROUTER"; then
    sed -i 's|<Route path="/admin/profiles"|<Route path="/admin/profiles/management" element={<ProfilesManagementPage />} />\n          <Route path="/admin/profiles"|' "$APP_ROUTER"
    echo "✅ Добавлен маршрут к старому интерфейсу"
  fi
fi

echo "🚀 Пересобираем клиентскую часть..."
cd /root/escort-project/client
export CI=false
export DISABLE_ESLINT_PLUGIN=true
export SKIP_PREFLIGHT_CHECK=true

# Выполняем сборку
npm run build:ignore

# Проверяем, была ли создана директория build
if [ -d "build" ]; then
  echo "📦 Директория build существует, копируем файлы..."
  # Копируем сборку в контейнер
  docker cp /root/escort-project/client/build/. escort-client:/usr/share/nginx/html/

  # Перезапускаем Nginx
  docker exec escort-client nginx -s reload
  
  echo "✅ Сборка скопирована в контейнер и Nginx перезапущен"
else
  echo "❌ Директория build не создана. Сборка не удалась!"
fi

# Создаем прямую ссылку на старый интерфейс
cat > /tmp/old-interface-link.html << 'END'
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Перенаправление</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background-color: #f5f5f5;
    }
    .container {
      text-align: center;
      padding: 2rem;
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      max-width: 500px;
    }
    .btn {
      display: inline-block;
      padding: 10px 20px;
      margin: 10px;
      background-color: #1976d2;
      color: white;
      text-decoration: none;
      border-radius: 4px;
      font-weight: bold;
    }
    .btn:hover {
      background-color: #1565c0;
    }
  </style>
</head>
<body>
  <div class="container">
    <h2>Выберите интерфейс</h2>
    <p>Вы можете использовать любой из доступных интерфейсов административной панели:</p>
    <a href="/admin/dashboard" class="btn">Новый интерфейс</a>
    <a href="/admin/profiles/management" class="btn">Старый интерфейс</a>
    <p>Для управления порядком анкет используйте кнопки со стрелками рядом с кнопками редактирования/удаления.</p>
  </div>
</body>
</html>
END

# Копируем страницу выбора интерфейса
docker cp /tmp/old-interface-link.html escort-client:/usr/share/nginx/html/admin-interface.html

echo "✅ Восстановление интерфейса завершено!"
echo "�� Для доступа к старому интерфейсу перейдите по адресу: https://eskortvsegorodarfreal.site/admin-interface.html"
echo "   или напрямую: https://eskortvsegorodarfreal.site/admin/profiles/management"
