import React, { useState, useEffect } from 'react';
import ProfileOrderButtons from '../../components/admin/ProfileOrderButtons';
import {
  Container,
  Box,
  Button,
  Grid,
  Card,
  CardContent,
  CardActions,
  CircularProgress,
  Alert,
  IconButton,
  Typography,
  Tooltip,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Check as CheckIcon,
  Block as BlockIcon,
  VerifiedUser as VerifiedIcon,
  ArrowUpward as ArrowUpIcon,
  ArrowDownward as ArrowDownIcon,
} from "@mui/icons-material";
import { api } from '../../utils/api';
import { Profile, City } from '../../types';
import ProfileEditor from '../../components/admin/ProfileEditor';

const ProfilesPage: React.FC = () => {
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [openEditor, setOpenEditor] = useState(false);
  const [selectedProfile, setSelectedProfile] = useState<Profile | null>(null);

  useEffect(() => {
    fetchProfiles();
    fetchCities();
  }, []);

  const fetchProfiles = async () => {
    try {
      const response = await api.get('/admin/profiles');
      setProfiles(response.data);
    } catch (error) {
      console.error('Error fetching profiles:', error);
      setError('Ошибка при загрузке анкет');
    } finally {
      setLoading(false);
    }
  };

  const fetchCities = async () => {
    try {
      const response = await api.get('/cities');
      setCities(response.data);
    } catch (error) {
      console.error('Error fetching cities:', error);
    }
  };

  const handleOpenEditor = (profile?: Profile) => {
    if (profile) {
      setSelectedProfile(profile);
    } else {
      setSelectedProfile(null);
    }
    setOpenEditor(true);
  };

  const handleCloseEditor = () => {
    setOpenEditor(false);
    setSelectedProfile(null);
  };

  const handleSaveProfile = async (profileData: Profile) => {
    try {
      if (selectedProfile) {
        await api.put(`/admin/profiles/${selectedProfile.id}`, profileData);
      } else {
        await api.post('/admin/profiles', profileData);
      }
      fetchProfiles();
      handleCloseEditor();
    } catch (error) {
      console.error('Error saving profile:', error);
      setError('Ошибка при сохранении анкеты');
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('Вы уверены, что хотите удалить эту анкету?')) {
      return;
    }

    try {
      await api.delete(`/admin/profiles/${id}`);
      fetchProfiles();
    } catch (error) {
      console.error('Error deleting profile:', error);
      setError('Ошибка при удалении анкеты');
    }
  };

  const handleMoveUp = async (id: number) => {

    try {

      await api.patch(`/admin/profiles/${id}/moveUp`);

      fetchProfiles(); // Обновляем список профилей

    } catch (error) {

      console.error("Error moving profile up:", error);

      setError("Ошибка при перемещении анкеты вверх");

    }

  };



  const handleMoveDown = async (id: number) => {

    try {

      await api.patch(`/admin/profiles/${id}/moveDown`);

      fetchProfiles(); // Обновляем список профилей

    } catch (error) {

      console.error("Error moving profile down:", error);

      setError("Ошибка при перемещении анкеты вниз");

    }

  };



  const handleToggleStatus = async (profile: Profile) => {
    try {
      await api.put(`/admin/profiles/${profile.id}`, { isActive: !profile.isActive });
      fetchProfiles();
    } catch (error) {
      console.error('Error toggling profile status:', error);
      setError('Ошибка при изменении статуса анкеты');
    }
  };

  const handleToggleVerification = async (profile: Profile) => {
    try {
      await api.put(`/admin/profiles/${profile.id}`, { isVerified: !profile.isVerified });
      fetchProfiles();
    } catch (error) {
      console.error('Error toggling verification status:', error);
      setError('Ошибка при изменении статуса верификации');
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="lg">
      <Box sx={{ mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h5">Управление анкетами</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => handleOpenEditor()}
        >
          Добавить анкету
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      <Grid container spacing={3}>
        {profiles.map((profile) => (
          <Grid item xs={12} sm={6} md={4} key={profile.id}>
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  {profile.name}, {profile.age} лет
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Город: {cities.find(c => c.id === profile.cityId)?.name}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Телефон: {profile.phone}
                </Typography>
                <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
                  <Typography variant="body2" color="text.secondary">
                    Статус: {profile.isActive ? 'Активна' : 'Неактивна'}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    • {profile.isVerified ? 'Проверена' : 'Не проверена'}
                  </Typography>
                </Box>
              </CardContent>
              <CardActions>
                <Tooltip title="Редактировать">
                  <IconButton onClick={() => handleOpenEditor(profile)} size="small">
                    <EditIcon />
                  </IconButton>
                </Tooltip>
                <Tooltip title="Удалить">
                  <IconButton onClick={() => handleDelete(profile.id)} size="small" color="error">
                    <DeleteIcon />
                  </IconButton>
                </Tooltip>
                <Tooltip title={profile.isActive ? "Деактивировать" : "Активировать"}>
                  <IconButton 
                    onClick={() => handleToggleStatus(profile)} 
                    size="small"
                    color={profile.isActive ? "success" : "warning"}
                  >
                    {profile.isActive ? <CheckIcon /> : <BlockIcon />}
                  </IconButton>
                </Tooltip>
                <Tooltip title={profile.isVerified ? "Отменить проверку" : "Подтвердить проверку"}>
                  <IconButton 
                    onClick={() => handleToggleVerification(profile)} 
                    size="small"
                    color={profile.isVerified ? "success" : "default"}
                  >
                    <VerifiedIcon />
                  </IconButton>
                </Tooltip>
                <Tooltip title="Переместить вверх">

                  <IconButton onClick={() => handleMoveUp(profile.id)} size="small">

                    <ArrowUpIcon />

                  </IconButton>

                </Tooltip>

                <Tooltip title="Переместить вниз">

                  <IconButton onClick={() => handleMoveDown(profile.id)} size="small">

                    <ArrowDownIcon />

                  </IconButton>

                </Tooltip>
                <ProfileOrderButtons profileId={profile.id} onSuccess={fetchProfiles} onError={setError} />
                <ProfileOrderButtons profileId={profile.id} onSuccess={fetchProfiles} onError={setError} />
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

      <ProfileEditor
        profile={selectedProfile || undefined}
        open={openEditor}
        onClose={handleCloseEditor}
        onSave={handleSaveProfile}
      />
    </Container>
  );
};

export default ProfilesPage; 
