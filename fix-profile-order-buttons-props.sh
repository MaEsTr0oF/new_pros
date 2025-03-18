#!/bin/bash
set -e

echo "🔧 Обновляем интерфейс ProfileOrderButtonsProps"

# Путь к компоненту
COMPONENT_PATH="/root/escort-project/client/src/components/admin/ProfileOrderButtons.tsx"

# Создаем резервную копию
cp $COMPONENT_PATH ${COMPONENT_PATH}.bak_props

# Полностью переписываем содержимое файла
cat > "$COMPONENT_PATH" << 'EOFINNER'
import React from 'react';
import { Button, Box, Tooltip } from '@mui/material';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownward';
import { api } from '../../api';

interface ProfileOrderButtonsProps {
  profileId: number;
  onOrderChange?: () => void;
  onSuccess?: () => Promise<void>; // Новый пропс для колбэка успешного выполнения
  onError?: (errorMessage: string) => void; // Новый пропс для обработки ошибок
}

/**
 * Компонент с кнопками для изменения порядка отображения профиля
 */
const ProfileOrderButtons: React.FC<ProfileOrderButtonsProps> = ({ 
  profileId, 
  onOrderChange,
  onSuccess,
  onError 
}) => {
  // Обработчик нажатия на кнопку "Вверх"
  const handleMoveUp = async () => {
    try {
      await api.profiles.moveUp(profileId);
      
      // Вызываем коллбэки при успешном выполнении
      if (onOrderChange) {
        onOrderChange();
      }
      if (onSuccess) {
        await onSuccess();
      }
    } catch (error) {
      console.error('Ошибка при перемещении профиля вверх:', error);
      // Вызываем коллбэк при ошибке
      if (onError) {
        onError('Не удалось переместить профиль вверх');
      }
    }
  };

  // Обработчик нажатия на кнопку "Вниз"
  const handleMoveDown = async () => {
    try {
      await api.profiles.moveDown(profileId);
      
      // Вызываем коллбэки при успешном выполнении
      if (onOrderChange) {
        onOrderChange();
      }
      if (onSuccess) {
        await onSuccess();
      }
    } catch (error) {
      console.error('Ошибка при перемещении профиля вниз:', error);
      // Вызываем коллбэк при ошибке
      if (onError) {
        onError('Не удалось переместить профиль вниз');
      }
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

echo "✅ Интерфейс ProfileOrderButtonsProps обновлен"
