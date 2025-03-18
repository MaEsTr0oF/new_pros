#!/bin/bash
set -e

echo "🔧 Проверяем страницу ProfilesPage на наличие дублированных компонентов"

# Путь к файлу
PROFILES_PAGE_PATH="/root/escort-project/client/src/pages/admin/ProfilesPage.tsx"

# Создаем резервную копию
cp $PROFILES_PAGE_PATH ${PROFILES_PAGE_PATH}.bak_dup

# Проверяем содержимое файла на наличие дублирующихся кнопок и исправляем
if grep -n "ProfileOrderButtons profileId={profile.id}" $PROFILES_PAGE_PATH | wc -l | grep -q "2"; then
  echo "⚠️ Обнаружены дублирующиеся компоненты ProfileOrderButtons"
  
  # Используем sed для замены двух последовательных строк с ProfileOrderButtons на одну
  sed -i -E '/ProfileOrderButtons profileId=\{profile\.id\}/,+1d;n' $PROFILES_PAGE_PATH
  
  echo "✅ Удалены дублирующиеся компоненты ProfileOrderButtons"
else
  echo "✅ Дублирующиеся компоненты не обнаружены"
fi

echo "🔧 Перезаписываем ProfilesPage для исправления всех проблем"

# Полностью перезаписываем файл для гарантии исправления всех проблем
cat > "$PROFILES_PAGE_PATH" << 'EOFINNER'
import React, { useState, useEffect } from 'react';
import ProfileOrderButtons from '../../components/admin/ProfileOrderButtons';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  CardMedia,
  CardActions,
  Button,
  CircularProgress,
  Alert,
  Tooltip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions
} from '@mui/material';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  VerifiedUser as VerifiedIcon,
  Add as AddIcon
} from '@mui/icons-material';
import { Link } from 'react-router-dom';
import { api } from '../../api';
import { Profile } from '../../types';
import ProfileEditor from '../../components/admin/ProfileEditor';

const ProfilesPage: React.FC = () => {
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [editorOpen, setEditorOpen] = useState(false);
  const [editingProfile, setEditingProfile] = useState<Profile | undefined>(undefined);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [profileToDelete, setProfileToDelete] = useState<Profile | null>(null);

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

  const handleCreateProfile = () => {
    setEditingProfile(undefined);
    setEditorOpen(true);
  };

  const handleEditProfile = (profile: Profile) => {
    setEditingProfile(profile);
    setEditorOpen(true);
  };

  const handleSaveProfile = async (profile: Profile) => {
    try {
      setLoading(true);
      
      if (profile.id) {
        // Обновление существующего профиля
        await api.profiles.update(profile.id, profile);
      } else {
        // Создание нового профиля
        await api.profiles.create(profile);
      }
      
      setEditorOpen(false);
      await fetchProfiles();
    } catch (err) {
      console.error('Ошибка при сохранении профиля:', err);
      setError('Не удалось сохранить профиль');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteClick = (profile: Profile) => {
    setProfileToDelete(profile);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    if (!profileToDelete) return;
    
    try {
      setLoading(true);
      await api.profiles.delete(profileToDelete.id);
      setDeleteDialogOpen(false);
      setProfileToDelete(null);
      await fetchProfiles();
    } catch (err) {
      console.error('Ошибка при удалении профиля:', err);
      setError('Не удалось удалить профиль');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteCancel = () => {
    setDeleteDialogOpen(false);
    setProfileToDelete(null);
  };

  const handleVerify = async (profileId: number) => {
    try {
      await api.profiles.verify(profileId);
      await fetchProfiles();
    } catch (err) {
      console.error('Ошибка при верификации профиля:', err);
      setError('Не удалось верифицировать профиль');
    }
  };

  return (
    <Container maxWidth="xl" sx={{ mt: 4, mb: 4 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" component="h1">
          Управление анкетами
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={handleCreateProfile}
        >
          Добавить анкету
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {loading && !editorOpen ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
          <CircularProgress />
        </Box>
      ) : (
        <Grid container spacing={3}>
          {profiles.map((profile) => (
            <Grid item xs={12} sm={6} md={4} key={profile.id}>
              <Card sx={{ 
                height: '100%', 
                display: 'flex', 
                flexDirection: 'column',
                opacity: profile.isActive ? 1 : 0.7
              }}>
                <CardMedia
                  component="img"
                  height="200"
                  image={profile.photos?.[0] || 'https://via.placeholder.com/300x200?text=Нет+фото'}
                  alt={profile.name}
                  sx={{ objectFit: 'cover' }}
                />
                <CardContent sx={{ flexGrow: 1 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <Typography variant="h6" component="div">
                      {profile.name}
                    </Typography>
                    {profile.isVerified && (
                      <Tooltip title="Верифицирован">
                        <VerifiedIcon color="primary" />
                      </Tooltip>
                    )}
                  </Box>
                  <Typography variant="body2" color="text.secondary">
                    {profile.age} лет, {profile.height} см, {profile.weight} кг
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {profile.city?.name || 'Неизвестный город'}, {profile.district || 'Район не указан'}
                  </Typography>
                  <Typography variant="body1" sx={{ mt: 1 }}>
                    {profile.price1Hour} ₽ / час
                  </Typography>
                </CardContent>
                <CardActions sx={{ justifyContent: 'space-between', p: 2 }}>
                  <Box>
                    <IconButton 
                      size="small" 
                      onClick={() => handleEditProfile(profile)}
                      title="Редактировать"
                    >
                      <EditIcon />
                    </IconButton>
                    <IconButton 
                      size="small" 
                      onClick={() => handleDeleteClick(profile)}
                      title="Удалить"
                    >
                      <DeleteIcon />
                    </IconButton>
                    {!profile.isVerified && (
                      <IconButton 
                        size="small" 
                        onClick={() => handleVerify(profile.id)}
                        title="Верифицировать"
                      >
                        <VerifiedIcon />
                      </IconButton>
                    )}
                  </Box>
                  <ProfileOrderButtons 
                    profileId={profile.id} 
                    onSuccess={fetchProfiles} 
                    onError={setError} 
                  />
                </CardActions>
              </Card>
            </Grid>
          ))}

          {profiles.length === 0 && !loading && (
            <Grid item xs={12}>
              <Typography variant="body1" align="center">
                Анкеты не найдены. Нажмите "Добавить анкету", чтобы создать новую.
              </Typography>
            </Grid>
          )}
        </Grid>
      )}

      <ProfileEditor
        profile={editingProfile}
        onSave={handleSaveProfile}
        onClose={() => setEditorOpen(false)}
        open={editorOpen}
      />

      <Dialog
        open={deleteDialogOpen}
        onClose={handleDeleteCancel}
      >
        <DialogTitle>
          Подтверждение удаления
        </DialogTitle>
        <DialogContent>
          {profileToDelete && (
            <Typography>
              Вы действительно хотите удалить анкету {profileToDelete.name}?
              Это действие нельзя будет отменить.
            </Typography>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleDeleteCancel}>Отмена</Button>
          <Button onClick={handleDeleteConfirm} color="error">Удалить</Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default ProfilesPage;
EOFINNER

echo "✅ Страница ProfilesPage успешно перезаписана"
