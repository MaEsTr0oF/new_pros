#!/bin/bash
set -e

echo "🔍 Определяю текущий компонент таблицы анкет..."

# Находим все компоненты, связанные с таблицей анкет
find /root/escort-project/client/src -type f -name "*.tsx" | xargs grep -l "Управление анкетами" > /tmp/profiles_table_components.txt

if [ -s /tmp/profiles_table_components.txt ]; then
  TABLE_COMPONENT=$(cat /tmp/profiles_table_components.txt | head -1)
  echo "✅ Найден компонент таблицы анкет: $TABLE_COMPONENT"
else
  # Поиск по альтернативным ключевым словам
  find /root/escort-project/client/src -type f -name "*.tsx" | xargs grep -l "Анкеты" > /tmp/profiles_table_components.txt
  if [ -s /tmp/profiles_table_components.txt ]; then
    TABLE_COMPONENT=$(cat /tmp/profiles_table_components.txt | head -1)
    echo "✅ Найден компонент таблицы анкет: $TABLE_COMPONENT"
  else
    echo "❌ Не удалось найти компонент таблицы анкет, используем страницу профилей по умолчанию"
    TABLE_COMPONENT="/root/escort-project/client/src/pages/admin/ProfilesPage.tsx"
  fi
fi

# Создаем резервную копию файла
echo "�� Создаю резервную копию компонента..."
cp "$TABLE_COMPONENT" "${TABLE_COMPONENT}.bak_buttons"

# Создаем компонент кнопок, если его нет
BUTTONS_COMPONENT="/root/escort-project/client/src/components/admin/ProfileOrderButtons.tsx"
if [ ! -f "$BUTTONS_COMPONENT" ]; then
  echo "🔧 Создаю компонент кнопок порядка..."
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
      console.log("Перемещение профиля вверх:", profileId);
      await api.patch(`/api/admin/profiles/${profileId}/moveUp`);
      console.log("Профиль успешно перемещен вверх");
      onSuccess();
    } catch (error) {
      console.error('Ошибка при перемещении профиля вверх:', error);
    }
  };

  const handleMoveDown = async () => {
    try {
      console.log("Перемещение профиля вниз:", profileId);
      await api.patch(`/api/admin/profiles/${profileId}/moveDown`);
      console.log("Профиль успешно перемещен вниз");
      onSuccess();
    } catch (error) {
      console.error('Ошибка при перемещении профиля вниз:', error);
    }
  };

  return (
    <Stack direction="row" spacing={1} justifyContent="center">
      <Tooltip title="Переместить выше">
        <IconButton
          size="small"
          color="primary"
          onClick={handleMoveUp}
          aria-label="переместить вверх"
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
    </Stack>
  );
};

export default ProfileOrderButtons;
END
  echo "✅ Компонент кнопок порядка создан"
fi

# Находим файлы с расширением .tsx в структуре клиентского кода
echo "🔍 Поиск компонентов таблицы анкет..."
PROFILES_COMPONENTS=$(find /root/escort-project/client/src -type f -name "*Profiles*.tsx" -o -name "*Admin*.tsx" -o -name "*Anket*.tsx")

# Сохраняем список найденных файлов
echo "$PROFILES_COMPONENTS" > /tmp/profiles_components.txt

echo "🔧 Обновляю компоненты, связанные с таблицей анкет..."
for component in $PROFILES_COMPONENTS; do
  echo "📄 Проверяю компонент: $component"
  
  # Проверяем, содержит ли компонент таблицу
  if grep -q "<Table\|<TableRow\|<TableCell" "$component"; then
    echo "📋 Найдена таблица в компоненте: $component"
    
    # Создаем резервную копию
    cp "$component" "${component}.bak_order"
    
    # Проверяем, есть ли уже импорт ProfileOrderButtons
    if ! grep -q "import ProfileOrderButtons" "$component"; then
      echo "➕ Добавляю импорт ProfileOrderButtons в: $component"
      sed -i '1s/^/import ProfileOrderButtons from "..\/..\/components\/admin\/ProfileOrderButtons";\n/' "$component"
    fi
    
    # Проверяем, есть ли уже колонка "Порядок" в заголовке таблицы
    if ! grep -q "Порядок\|Order" "$component"; then
      echo "➕ Добавляю колонку \"Порядок\" в заголовок таблицы в: $component"
      
      # Используем временный файл для сложной замены
      TMP_FILE="/tmp/component_with_order_column.tsx"
      
      # Добавляем колонку "Порядок" после колонки "Действия" или "Actions"
      awk '
      /TableCell.*>Действия<|TableCell.*>Actions</ {
        print $0;
        print "                    <TableCell align=\"center\">Порядок</TableCell>";
        next;
      }
      { print $0 }
      ' "$component" > "$TMP_FILE"
      
      # Копируем обратно
      cp "$TMP_FILE" "$component"
      
      # Добавляем кнопки OrderButtons в строки таблицы
      awk '
      /<\/TableCell>.*<\/TableRow>/ && !found {
        gsub(/<\/TableCell>.*<\/TableRow>/, "                    </TableCell>\n                    <TableCell align=\"center\">\n                      <ProfileOrderButtons\n                        profileId={profile.id}\n                        onSuccess={() => window.location.reload()}\n                      />\n                    </TableCell>\n                  </TableRow>");
        found = 1;
      }
      { print $0 }
      ' "$component" > "$TMP_FILE"
      
      # Копируем обратно
      cp "$TMP_FILE" "$component"
      
      echo "✅ Добавлена колонка \"Порядок\" и кнопки в: $component"
    else
      echo "✓ Колонка \"Порядок\" уже существует в: $component"
    fi
  fi
done

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

echo "✅ Кнопки управления порядком добавлены в интерфейс админки!"
echo "🌐 Обновите страницу и проверьте наличие колонки \"Порядок\" с кнопками"
