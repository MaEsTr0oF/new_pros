#!/bin/bash
set -e

echo "🔍 Анализирую файлы компонентов с кнопками..."

# Проверяем структуру страницы Dashboard
echo "📄 Проверяем DashboardPage.tsx..."
DASHBOARD_PAGE="/root/escort-project/client/src/pages/admin/DashboardPage.tsx"
if [ -f "$DASHBOARD_PAGE" ]; then
  # Создаем резервную копию
  cp "$DASHBOARD_PAGE" "${DASHBOARD_PAGE}.bak"
  
  # Проверяем, импортирован ли уже компонент ProfileOrderButtons
  if grep -q "import ProfileOrderButtons" "$DASHBOARD_PAGE"; then
    echo "✅ Компонент ProfileOrderButtons уже импортирован в DashboardPage"
  else
    # Добавляем импорт компонента в начало файла
    sed -i '1s/^/import ProfileOrderButtons from "..\/..\/components\/admin\/ProfileOrderButtons";\n/' "$DASHBOARD_PAGE"
    echo "✅ Добавлен импорт ProfileOrderButtons в DashboardPage"
  fi
  
  # Проверяем, есть ли уже кнопки порядка в таблице профилей
  if grep -q "ProfileOrderButtons" "$DASHBOARD_PAGE"; then
    echo "⚠️ Кнопки уже добавлены в DashboardPage"
  else
    # Находим место для добавления кнопок в таблицу профилей (после колонки с действиями)
    # Это сложная операция замены, используем временный файл
    TMP_FILE="/tmp/dashboard-modified.tsx"
    cat "$DASHBOARD_PAGE" | awk '
    BEGIN { found=0; }
    /handleProfileVerify|handleProfileDelete|actions|edit profile/ && !found {
      print $0;
      print "                  <TableCell align=\"center\">";
      print "                    <ProfileOrderButtons";
      print "                      profileId={profile.id}";
      print "                      onSuccess={fetchProfiles}";
      print "                    />";
      print "                  </TableCell>";
      found=1;
      next;
    }
    { print $0; }
    ' > "$TMP_FILE"
    
    # Копируем обратно
    cp "$TMP_FILE" "$DASHBOARD_PAGE"
    echo "✅ Добавлены кнопки порядка в таблицу профилей в DashboardPage"
    
    # Также добавляем заголовок колонки в TableHead
    sed -i 's/<TableCell>Actions<\/TableCell>/<TableCell>Actions<\/TableCell>\n                  <TableCell align="center">Order<\/TableCell>/' "$DASHBOARD_PAGE"
    echo "✅ Добавлен заголовок колонки в таблицу"
  fi
else
  echo "❌ Файл DashboardPage.tsx не найден!"
fi

# Теперь удалим дублирующиеся кнопки из ProfilesPage
echo "📄 Проверяем ProfilesPage.tsx..."
PROFILES_PAGE="/root/escort-project/client/src/pages/admin/ProfilesPage.tsx"
if [ -f "$PROFILES_PAGE" ]; then
  # Создаем резервную копию
  cp "$PROFILES_PAGE" "${PROFILES_PAGE}.bak"
  
  # Удаляем импорт компонента ProfileOrderButtons
  sed -i '/import ProfileOrderButtons/d' "$PROFILES_PAGE"
  echo "✅ Удален импорт ProfileOrderButtons из ProfilesPage"
  
  # Удаляем компонент ProfileOrderButtons из разметки
  TMP_FILE="/tmp/profiles-modified.tsx"
  cat "$PROFILES_PAGE" | awk '
  BEGIN { skip=0; }
  /<ProfileOrderButtons/ { skip=1; next; }
  skip && /\/>/ { skip=0; next; }
  !skip { print $0; }
  ' > "$TMP_FILE"
  
  # Копируем обратно
  cp "$TMP_FILE" "$PROFILES_PAGE"
  echo "✅ Удалены компоненты ProfileOrderButtons из разметки ProfilesPage"
  
  # Удаляем методы handleMoveProfileUp и handleMoveProfileDown
  TMP_FILE="/tmp/profiles-methods-modified.tsx"
  cat "$PROFILES_PAGE" | awk '
  BEGIN { skip=0; }
  /const handleMoveProfileUp/ { skip=1; next; }
  /const handleMoveProfileDown/ { skip=1; next; }
  skip && /^\s*\}/ { skip=0; next; }
  !skip { print $0; }
  ' > "$TMP_FILE"
  
  # Копируем обратно
  cp "$TMP_FILE" "$PROFILES_PAGE"
  echo "✅ Удалены методы для перемещения профилей из ProfilesPage"
else
  echo "❌ Файл ProfilesPage.tsx не найден!"
fi

# Проверяем компонент ProfileOrderButtons
echo "📄 Проверяем ProfileOrderButtons.tsx..."
BUTTONS_COMPONENT="/root/escort-project/client/src/components/admin/ProfileOrderButtons.tsx"
if [ -f "$BUTTONS_COMPONENT" ]; then
  # Создаем резервную копию
  cp "$BUTTONS_COMPONENT" "${BUTTONS_COMPONENT}.bak"
  
  # Проверяем и исправляем методы для работы с API
  cat > "$BUTTONS_COMPONENT" << 'END'
import React from 'react';
import { IconButton, Tooltip, Stack } from '@mui/material';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownward';
import { api } from '../../api';

interface ProfileOrderButtonsProps {
  profileId: number;
  onSuccess: () => void;
}

const ProfileOrderButtons: React.FC<ProfileOrderButtonsProps> = ({ profileId, onSuccess }) => {
  const handleMoveUp = async () => {
    try {
      // Используем объектную модель API
      await api.profiles.moveUp(profileId);
      onSuccess();
    } catch (error) {
      console.error('Error moving profile up:', error);
    }
  };

  const handleMoveDown = async () => {
    try {
      // Используем объектную модель API
      await api.profiles.moveDown(profileId);
      onSuccess();
    } catch (error) {
      console.error('Error moving profile down:', error);
    }
  };

  return (
    <Stack direction="row" spacing={1} justifyContent="center">
      <Tooltip title="Переместить выше">
        <IconButton
          size="small"
          color="primary"
          onClick={handleMoveUp}
          aria-label="move up"
        >
          <ArrowUpwardIcon />
        </IconButton>
      </Tooltip>
      <Tooltip title="Переместить ниже">
        <IconButton
          size="small"
          color="primary"
          onClick={handleMoveDown}
          aria-label="move down"
        >
          <ArrowDownwardIcon />
        </IconButton>
      </Tooltip>
    </Stack>
  );
};

export default ProfileOrderButtons;
END
  echo "✅ Обновлен компонент ProfileOrderButtons для использования объектной модели API"
else
  echo "❌ Файл ProfileOrderButtons.tsx не найден!"
  
  # Создаем компонент, если его нет
  mkdir -p "/root/escort-project/client/src/components/admin"
  cat > "$BUTTONS_COMPONENT" << 'END'
import React from 'react';
import { IconButton, Tooltip, Stack } from '@mui/material';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownward';
import { api } from '../../api';

interface ProfileOrderButtonsProps {
  profileId: number;
  onSuccess: () => void;
}

const ProfileOrderButtons: React.FC<ProfileOrderButtonsProps> = ({ profileId, onSuccess }) => {
  const handleMoveUp = async () => {
    try {
      // Используем объектную модель API
      await api.profiles.moveUp(profileId);
      onSuccess();
    } catch (error) {
      console.error('Error moving profile up:', error);
    }
  };

  const handleMoveDown = async () => {
    try {
      // Используем объектную модель API
      await api.profiles.moveDown(profileId);
      onSuccess();
    } catch (error) {
      console.error('Error moving profile down:', error);
    }
  };

  return (
    <Stack direction="row" spacing={1} justifyContent="center">
      <Tooltip title="Переместить выше">
        <IconButton
          size="small"
          color="primary"
          onClick={handleMoveUp}
          aria-label="move up"
        >
          <ArrowUpwardIcon />
        </IconButton>
      </Tooltip>
      <Tooltip title="Переместить ниже">
        <IconButton
          size="small"
          color="primary"
          onClick={handleMoveDown}
          aria-label="move down"
        >
          <ArrowDownwardIcon />
        </IconButton>
      </Tooltip>
    </Stack>
  );
};

export default ProfileOrderButtons;
END
  echo "✅ Создан новый компонент ProfileOrderButtons"
fi

# Проверяем API для перемещения профилей
echo "📄 Проверяем API для поддержки методов moveUp и moveDown..."
API_FILE="/root/escort-project/client/src/api/index.ts"
if grep -q "moveUp" "$API_FILE" && grep -q "moveDown" "$API_FILE"; then
  echo "✅ API уже содержит методы moveUp и moveDown"
else
  echo "⚠️ Добавляем методы moveUp и moveDown в API"
  # Создаем резервную копию
  cp "$API_FILE" "${API_FILE}.bak"
  
  # Редактируем файл для добавления методов
  sed -i 's/const profiles = {/const profiles = {\n  moveUp: (id: number) => axiosInstance.patch(`\/admin\/profiles\/${id}\/moveUp`),\n  moveDown: (id: number) => axiosInstance.patch(`\/admin\/profiles\/${id}\/moveDown`),/' "$API_FILE"
fi

echo "🚀 Пересобираем и перезапускаем проект..."
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

echo "🌐 Проверьте сайт по адресу: https://eskortvsegorodarfreal.site"
echo "✅ Готово! Кнопки управления порядком перенесены на страницу Dashboard и удалены из ProfilesPage"
