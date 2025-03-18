#!/bin/bash
set -e

echo "🔧 Проверяем наличие компонента ProfileOrderButtons"

# Путь к директории компонентов
COMPONENTS_DIR="/root/escort-project/client/src/components/admin"

# Проверяем наличие компонента
COMPONENT_PATH="${COMPONENTS_DIR}/ProfileOrderButtons.tsx"

if [ ! -f "$COMPONENT_PATH" ]; then
  # Создаем директорию, если она не существует
  mkdir -p "$COMPONENTS_DIR"
  
  # Создаем компонент ProfileOrderButtons
  cat > "$COMPONENT_PATH" << 'EOFINNER'
import React from 'react';
import { Button, Box, Tooltip } from '@mui/material';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownward';
import axios from 'axios';
import { API_URL } from '../../config';

interface ProfileOrderButtonsProps {
  profileId: number;
  onOrderChange?: () => void;
}

/**
 * Компонент с кнопками для изменения порядка отображения профиля
 */
const ProfileOrderButtons: React.FC<ProfileOrderButtonsProps> = ({ profileId, onOrderChange }) => {
  const token = localStorage.getItem('token');

  // Обработчик нажатия на кнопку "Вверх"
  const handleMoveUp = async () => {
    try {
      if (!token) {
        console.error('Нет токена авторизации');
        return;
      }

      await axios.patch(
        `${API_URL}/admin/profiles/${profileId}/moveUp`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`
          }
        }
      );

      // Вызываем коллбэк для обновления списка
      if (onOrderChange) {
        onOrderChange();
      }
    } catch (error) {
      console.error('Ошибка при перемещении профиля вверх:', error);
    }
  };

  // Обработчик нажатия на кнопку "Вниз"
  const handleMoveDown = async () => {
    try {
      if (!token) {
        console.error('Нет токена авторизации');
        return;
      }

      await axios.patch(
        `${API_URL}/admin/profiles/${profileId}/moveDown`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`
          }
        }
      );

      // Вызываем коллбэк для обновления списка
      if (onOrderChange) {
        onOrderChange();
      }
    } catch (error) {
      console.error('Ошибка при перемещении профиля вниз:', error);
    }
  };

  return (
    <Box sx={{ display: 'flex', gap: 1 }}>
      <Tooltip title="Переместить вверх">
        <Button
          size="small"
          variant="outlined"
          color="primary"
          onClick={handleMoveUp}
          sx={{ minWidth: 'auto', p: 0.5 }}
        >
          <ArrowUpwardIcon fontSize="small" />
        </Button>
      </Tooltip>
      <Tooltip title="Переместить вниз">
        <Button
          size="small"
          variant="outlined"
          color="primary"
          onClick={handleMoveDown}
          sx={{ minWidth: 'auto', p: 0.5 }}
        >
          <ArrowDownwardIcon fontSize="small" />
        </Button>
      </Tooltip>
    </Box>
  );
};

export default ProfileOrderButtons;
EOFINNER

  echo "✅ Компонент ProfileOrderButtons создан"
else
  echo "✅ Компонент ProfileOrderButtons уже существует"
fi
