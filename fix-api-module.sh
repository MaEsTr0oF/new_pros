#!/bin/bash
set -e

echo "🔧 Создаем модуль API для компонентов"

# Создаем директорию для API
API_DIR="/root/escort-project/client/src/api"
mkdir -p "$API_DIR"

# Создаем файл API для профилей
cat > "${API_DIR}/index.ts" << 'EOFINNER'
import axios from 'axios';
import { API_URL } from '../config';

const getToken = () => localStorage.getItem('token');

// Функция для создания заголовков с токеном авторизации
export const getAuthHeaders = () => {
  const token = getToken();
  return {
    headers: {
      Authorization: token ? `Bearer ${token}` : ''
    }
  };
};

// API для профилей
export const profilesApi = {
  // Получить все профили
  getAll: async () => {
    return axios.get(`${API_URL}/admin/profiles`, getAuthHeaders());
  },
  
  // Получить профиль по ID
  getById: async (id: number) => {
    return axios.get(`${API_URL}/admin/profiles/${id}`, getAuthHeaders());
  },
  
  // Создать новый профиль
  create: async (profileData: any) => {
    return axios.post(`${API_URL}/admin/profiles`, profileData, getAuthHeaders());
  },
  
  // Обновить существующий профиль
  update: async (id: number, profileData: any) => {
    return axios.put(`${API_URL}/admin/profiles/${id}`, profileData, getAuthHeaders());
  },
  
  // Удалить профиль
  delete: async (id: number) => {
    return axios.delete(`${API_URL}/admin/profiles/${id}`, getAuthHeaders());
  },
  
  // Переместить профиль вверх
  moveUp: async (id: number) => {
    return axios.patch(`${API_URL}/admin/profiles/${id}/moveUp`, {}, getAuthHeaders());
  },
  
  // Переместить профиль вниз
  moveDown: async (id: number) => {
    return axios.patch(`${API_URL}/admin/profiles/${id}/moveDown`, {}, getAuthHeaders());
  },
  
  // Верифицировать профиль
  verify: async (id: number) => {
    return axios.patch(`${API_URL}/admin/profiles/${id}/verify`, {}, getAuthHeaders());
  }
};

// API для городов
export const citiesApi = {
  // Получить все города
  getAll: async () => {
    return axios.get(`${API_URL}/cities`);
  },
  
  // Создать новый город
  create: async (cityData: any) => {
    return axios.post(`${API_URL}/admin/cities`, cityData, getAuthHeaders());
  },
  
  // Обновить существующий город
  update: async (id: number, cityData: any) => {
    return axios.put(`${API_URL}/admin/cities/${id}`, cityData, getAuthHeaders());
  },
  
  // Удалить город
  delete: async (id: number) => {
    return axios.delete(`${API_URL}/admin/cities/${id}`, getAuthHeaders());
  }
};

// API для аутентификации
export const authApi = {
  // Вход в систему
  login: async (username: string, password: string) => {
    return axios.post(`${API_URL}/auth/login`, { username, password });
  },
  
  // Проверка текущего токена
  checkToken: async () => {
    return axios.get(`${API_URL}/admin/profile`, getAuthHeaders());
  }
};

export default {
  profiles: profilesApi,
  cities: citiesApi,
  auth: authApi
};
EOFINNER

echo "✅ Модуль API создан"

# Обновляем компонент ProfileOrderButtons
COMPONENT_PATH="/root/escort-project/client/src/components/admin/ProfileOrderButtons.tsx"

# Создаем резервную копию
cp $COMPONENT_PATH ${COMPONENT_PATH}.bak

# Обновляем содержимое файла
cat > "$COMPONENT_PATH" << 'EOFINNER'
import React from 'react';
import { Button, Box, Tooltip } from '@mui/material';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownward';
import { profilesApi } from '../../api';

interface ProfileOrderButtonsProps {
  profileId: number;
  onOrderChange?: () => void;
}

/**
 * Компонент с кнопками для изменения порядка отображения профиля
 */
const ProfileOrderButtons: React.FC<ProfileOrderButtonsProps> = ({ profileId, onOrderChange }) => {
  // Обработчик нажатия на кнопку "Вверх"
  const handleMoveUp = async () => {
    try {
      await profilesApi.moveUp(profileId);
      
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
      await profilesApi.moveDown(profileId);
      
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

echo "✅ Компонент ProfileOrderButtons обновлен"
