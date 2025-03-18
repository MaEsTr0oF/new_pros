#!/bin/bash
set -e

echo "🔧 Переписываем DashboardPage.tsx полностью"

# Путь к файлу
DASHBOARD_PATH="/root/escort-project/client/src/pages/admin/DashboardPage.tsx"

# Создаем резервную копию
cp $DASHBOARD_PATH ${DASHBOARD_PATH}.bak_full

# Полное содержимое нового файла
cat > "$DASHBOARD_PATH" << 'EOFINNER'
import React, { useState, useEffect } from 'react';
import {
  Container,
  Box,
  Typography,
  Grid,
  Paper,
  CircularProgress,
  Alert,
  IconButton
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Check as CheckIcon,
  ArrowUpward as ArrowUpIcon,
  ArrowDownward as ArrowDownIcon
} from '@mui/icons-material';
import { api } from '../../api';
import { Profile } from '../../types';

const DashboardPage: React.FC = () => {
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchProfiles = async () => {
    try {
      setLoading(true);
      const response = await api.profiles.getAll();
      setProfiles(response.data);
      setError('');
    } catch (err) {
      console.error('Ошибка при загрузке профилей:', err);
      setError('Не удалось загрузить профили');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProfiles();
  }, []);

  const handleProfileDelete = async (id: number) => {
    if (window.confirm('Вы уверены, что хотите удалить профиль?')) {
      try {
        await api.profiles.delete(id);
        setProfiles(profiles.filter(profile => profile.id !== id));
      } catch (err) {
        console.error('Ошибка при удалении профиля:', err);
        setError('Не удалось удалить профиль');
      }
    }
  };

  const handleProfileVerify = async (id: number) => {
    try {
      await api.profiles.verify(id);
      fetchProfiles(); // Перезагружаем профили после верификации
    } catch (err) {
      console.error('Ошибка при верификации профиля:', err);
      setError('Не удалось верифицировать профиль');
    }
  };

  const handleMoveProfileUp = async (id: number) => {
    try {
      await api.profiles.moveUp(id);
      fetchProfiles(); // Перезагружаем профили после изменения порядка
    } catch (err) {
      console.error('Ошибка при перемещении профиля вверх:', err);
      setError('Не удалось переместить профиль вверх');
    }
  };

  const handleMoveProfileDown = async (id: number) => {
    try {
      await api.profiles.moveDown(id);
      fetchProfiles(); // Перезагружаем профили после изменения порядка
    } catch (err) {
      console.error('Ошибка при перемещении профиля вниз:', err);
      setError('Не удалось переместить профиль вниз');
    }
  };

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Typography variant="h4" gutterBottom>
        Панель управления
      </Typography>
      
      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}
      
      <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
          <Typography variant="h6">Анкеты</Typography>
          <IconButton
            color="primary"
            aria-label="Добавить профиль"
            component="a"
            href="/admin/profiles/new"
          >
            <AddIcon />
          </IconButton>
        </Box>
        
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
            <CircularProgress />
          </Box>
        ) : (
          <Grid container spacing={2}>
            {profiles.map(profile => (
              <Grid item xs={12} key={profile.id}>
                <Paper 
                  elevation={1} 
                  sx={{ 
                    p: 2, 
                    display: 'flex', 
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    backgroundColor: profile.isActive ? 'white' : '#f5f5f5'
                  }}
                >
                  <Box>
                    <Typography variant="subtitle1">
                      {profile.name} ({profile.age} лет)
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {profile.city?.name || ''} • {profile.price1Hour} ₽/час
                    </Typography>
                  </Box>
                  <Box sx={{ display: 'flex', gap: 1 }}>
                    <IconButton 
                      size="small" 
                      onClick={() => handleMoveProfileUp(profile.id)}
                      title="Переместить вверх"
                    >
                      <ArrowUpIcon fontSize="small" />
                    </IconButton>
                    <IconButton 
                      size="small" 
                      onClick={() => handleMoveProfileDown(profile.id)}
                      title="Переместить вниз"
                    >
                      <ArrowDownIcon fontSize="small" />
                    </IconButton>
                    <IconButton 
                      size="small" 
                      color={profile.isVerified ? "success" : "default"}
                      onClick={() => handleProfileVerify(profile.id)}
                      title={profile.isVerified ? "Верифицировано" : "Верифицировать"}
                    >
                      <CheckIcon fontSize="small" />
                    </IconButton>
                    <IconButton 
                      size="small" 
                      color="primary"
                      component="a"
                      href={`/admin/profiles/${profile.id}/edit`}
                      title="Редактировать"
                    >
                      <EditIcon fontSize="small" />
                    </IconButton>
                    <IconButton 
                      size="small" 
                      color="error"
                      onClick={() => handleProfileDelete(profile.id)}
                      title="Удалить"
                    >
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </Box>
                </Paper>
              </Grid>
            ))}
            {profiles.length === 0 && (
              <Grid item xs={12}>
                <Typography variant="body1" sx={{ p: 2, textAlign: 'center' }}>
                  Нет анкет. Нажмите "+" чтобы добавить новую анкету.
                </Typography>
              </Grid>
            )}
          </Grid>
        )}
      </Paper>
    </Container>
  );
};

export default DashboardPage;
EOFINNER

echo "✅ DashboardPage.tsx полностью переписан"
