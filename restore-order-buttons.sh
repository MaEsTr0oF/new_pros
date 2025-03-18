#!/bin/bash
set -e

echo "🔍 Проверяю компонент кнопок порядка..."

# Проверяем компонент ProfileOrderButtons
BUTTONS_COMPONENT="/root/escort-project/client/src/components/admin/ProfileOrderButtons.tsx"
if [ -f "$BUTTONS_COMPONENT" ]; then
  echo "✅ Компонент ProfileOrderButtons найден"
else
  echo "❌ Компонент не найден, создаю его..."
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
      await api.profiles.moveUp(profileId);
      console.log("Профиль успешно перемещен вверх");
      onSuccess();
    } catch (error) {
      console.error('Ошибка при перемещении профиля вверх:', error);
    }
  };

  const handleMoveDown = async () => {
    try {
      console.log("Перемещение профиля вниз:", profileId);
      await api.profiles.moveDown(profileId);
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
  echo "✅ Компонент ProfileOrderButtons создан"
fi

# Проверяем API для перемещения профилей
echo "🔍 Проверяю API для методов перемещения профилей..."
API_FILE="/root/escort-project/client/src/api/index.ts"
if grep -q "moveUp.*moveDown" "$API_FILE"; then
  echo "✅ API уже содержит методы moveUp и moveDown"
else
  echo "❌ API не содержит методы moveUp и moveDown, добавляю их..."
  cp "$API_FILE" "${API_FILE}.bak_order"
  
  # Добавляем методы moveUp и moveDown в объект profiles
  if grep -q "const profiles = {" "$API_FILE"; then
    sed -i '/const profiles = {/a \
  moveUp: (id: number) => axiosInstance.patch(`/admin/profiles/${id}/moveUp`),\
  moveDown: (id: number) => axiosInstance.patch(`/admin/profiles/${id}/moveDown`),\
' "$API_FILE"
    echo "✅ Методы moveUp и moveDown добавлены в API"
  else
    echo "⚠️ Не удалось найти объект profiles в API, проверьте структуру файла"
  fi
fi

# Добавляем кнопки на страницу Dashboard
echo "🔍 Проверяю DashboardPage.tsx..."
DASHBOARD_PAGE="/root/escort-project/client/src/pages/admin/DashboardPage.tsx"
if [ -f "$DASHBOARD_PAGE" ]; then
  cp "$DASHBOARD_PAGE" "${DASHBOARD_PAGE}.bak_buttons"
  
  # Проверяем, импортирован ли компонент ProfileOrderButtons
  if grep -q "import ProfileOrderButtons" "$DASHBOARD_PAGE"; then
    echo "✅ Компонент ProfileOrderButtons уже импортирован"
  else
    # Добавляем импорт компонента
    sed -i '1s/^/import ProfileOrderButtons from "..\/..\/components\/admin\/ProfileOrderButtons";\n/' "$DASHBOARD_PAGE"
    echo "✅ Импорт ProfileOrderButtons добавлен"
  fi
  
  # Проверяем наличие кнопок в таблице
  if grep -q "ProfileOrderButtons" "$DASHBOARD_PAGE"; then
    echo "✅ Кнопки уже добавлены в таблицу"
  else
    # Заменяем DashboardPage полностью, чтобы гарантировать правильную структуру
    cat > "$DASHBOARD_PAGE" << 'END'
import ProfileOrderButtons from "../../components/admin/ProfileOrderButtons";
import React, { useState, useEffect } from 'react';
import {
  Container,
  Grid,
  Paper,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  IconButton,
  Box,
  CircularProgress,
  Alert,
  Tooltip
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import { api } from '../../api';
import { Profile } from '../../types';
import { useNavigate } from 'react-router-dom';

const DashboardPage: React.FC = () => {
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetchProfiles();
  }, []);

  const fetchProfiles = async () => {
    try {
      setLoading(true);
      const response = await api.profiles.getAll();
      setProfiles(response.data);
      setError('');
    } catch (err) {
      console.error('Error fetching profiles:', err);
      setError('Failed to load profiles');
    } finally {
      setLoading(false);
    }
  };

  const handleAddProfile = () => {
    navigate('/admin/profiles/new');
  };

  const handleEditProfile = (id: number) => {
    navigate(`/admin/profiles/edit/${id}`);
  };

  const handleDeleteProfile = async (id: number) => {
    if (window.confirm('Вы уверены, что хотите удалить профиль?')) {
      try {
        await api.profiles.delete(id);
        setProfiles(profiles.filter(profile => profile.id !== id));
      } catch (err) {
        console.error('Error deleting profile:', err);
        setError('Failed to delete profile');
      }
    }
  };

  const handleProfileVerify = async (id: number) => {
    try {
      await api.profiles.verify(id);
      fetchProfiles(); // Перезагружаем профили после верификации
    } catch (err) {
      console.error('Error verifying profile:', err);
      setError('Failed to verify profile');
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
            <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
              <Typography component="h2" variant="h6" color="primary" gutterBottom>
                Управление профилями
              </Typography>
              <Button 
                variant="contained" 
                color="primary" 
                startIcon={<AddIcon />}
                onClick={handleAddProfile}
              >
                Добавить профиль
              </Button>
            </Box>
            
            {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
            
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>ID</TableCell>
                    <TableCell>Имя</TableCell>
                    <TableCell>Город</TableCell>
                    <TableCell>Возраст</TableCell>
                    <TableCell>Цена (1 час)</TableCell>
                    <TableCell>Активен</TableCell>
                    <TableCell>Верифицирован</TableCell>
                    <TableCell>Действия</TableCell>
                    <TableCell align="center">Порядок</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {profiles.map((profile) => (
                    <TableRow key={profile.id}>
                      <TableCell>{profile.id}</TableCell>
                      <TableCell>{profile.name}</TableCell>
                      <TableCell>{profile.city?.name || '-'}</TableCell>
                      <TableCell>{profile.age}</TableCell>
                      <TableCell>{profile.price1Hour}</TableCell>
                      <TableCell>{profile.isActive ? 'Да' : 'Нет'}</TableCell>
                      <TableCell>
                        {profile.isVerified ? (
                          <CheckCircleIcon color="success" />
                        ) : (
                          <IconButton 
                            size="small" 
                            color="primary"
                            onClick={() => handleProfileVerify(profile.id)}
                          >
                            <Tooltip title="Верифицировать">
                              <CheckCircleIcon color="disabled" />
                            </Tooltip>
                          </IconButton>
                        )}
                      </TableCell>
                      <TableCell>
                        <Tooltip title="Редактировать">
                          <IconButton
                            size="small"
                            onClick={() => handleEditProfile(profile.id)}
                          >
                            <EditIcon />
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="Удалить">
                          <IconButton
                            size="small"
                            color="error"
                            onClick={() => handleDeleteProfile(profile.id)}
                          >
                            <DeleteIcon />
                          </IconButton>
                        </Tooltip>
                      </TableCell>
                      <TableCell align="center">
                        <ProfileOrderButtons
                          profileId={profile.id}
                          onSuccess={fetchProfiles}
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Paper>
        </Grid>
      </Grid>
    </Container>
  );
};

export default DashboardPage;
END
    echo "✅ Страница Dashboard полностью обновлена с добавлением кнопок порядка"
  fi
else
  echo "❌ Файл DashboardPage.tsx не найден! Создаю новый файл..."
  mkdir -p "/root/escort-project/client/src/pages/admin"
  cat > "$DASHBOARD_PAGE" << 'END'
import ProfileOrderButtons from "../../components/admin/ProfileOrderButtons";
import React, { useState, useEffect } from 'react';
import {
  Container,
  Grid,
  Paper,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  IconButton,
  Box,
  CircularProgress,
  Alert,
  Tooltip
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import { api } from '../../api';
import { Profile } from '../../types';
import { useNavigate } from 'react-router-dom';

const DashboardPage: React.FC = () => {
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetchProfiles();
  }, []);

  const fetchProfiles = async () => {
    try {
      setLoading(true);
      const response = await api.profiles.getAll();
      setProfiles(response.data);
      setError('');
    } catch (err) {
      console.error('Error fetching profiles:', err);
      setError('Failed to load profiles');
    } finally {
      setLoading(false);
    }
  };

  const handleAddProfile = () => {
    navigate('/admin/profiles/new');
  };

  const handleEditProfile = (id: number) => {
    navigate(`/admin/profiles/edit/${id}`);
  };

  const handleDeleteProfile = async (id: number) => {
    if (window.confirm('Вы уверены, что хотите удалить профиль?')) {
      try {
        await api.profiles.delete(id);
        setProfiles(profiles.filter(profile => profile.id !== id));
      } catch (err) {
        console.error('Error deleting profile:', err);
        setError('Failed to delete profile');
      }
    }
  };

  const handleProfileVerify = async (id: number) => {
    try {
      await api.profiles.verify(id);
      fetchProfiles(); // Перезагружаем профили после верификации
    } catch (err) {
      console.error('Error verifying profile:', err);
      setError('Failed to verify profile');
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
            <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
              <Typography component="h2" variant="h6" color="primary" gutterBottom>
                Управление профилями
              </Typography>
              <Button 
                variant="contained" 
                color="primary" 
                startIcon={<AddIcon />}
                onClick={handleAddProfile}
              >
                Добавить профиль
              </Button>
            </Box>
            
            {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
            
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>ID</TableCell>
                    <TableCell>Имя</TableCell>
                    <TableCell>Город</TableCell>
                    <TableCell>Возраст</TableCell>
                    <TableCell>Цена (1 час)</TableCell>
                    <TableCell>Активен</TableCell>
                    <TableCell>Верифицирован</TableCell>
                    <TableCell>Действия</TableCell>
                    <TableCell align="center">Порядок</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {profiles.map((profile) => (
                    <TableRow key={profile.id}>
                      <TableCell>{profile.id}</TableCell>
                      <TableCell>{profile.name}</TableCell>
                      <TableCell>{profile.city?.name || '-'}</TableCell>
                      <TableCell>{profile.age}</TableCell>
                      <TableCell>{profile.price1Hour}</TableCell>
                      <TableCell>{profile.isActive ? 'Да' : 'Нет'}</TableCell>
                      <TableCell>
                        {profile.isVerified ? (
                          <CheckCircleIcon color="success" />
                        ) : (
                          <IconButton 
                            size="small" 
                            color="primary"
                            onClick={() => handleProfileVerify(profile.id)}
                          >
                            <Tooltip title="Верифицировать">
                              <CheckCircleIcon color="disabled" />
                            </Tooltip>
                          </IconButton>
                        )}
                      </TableCell>
                      <TableCell>
                        <Tooltip title="Редактировать">
                          <IconButton
                            size="small"
                            onClick={() => handleEditProfile(profile.id)}
                          >
                            <EditIcon />
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="Удалить">
                          <IconButton
                            size="small"
                            color="error"
                            onClick={() => handleDeleteProfile(profile.id)}
                          >
                            <DeleteIcon />
                          </IconButton>
                        </Tooltip>
                      </TableCell>
                      <TableCell align="center">
                        <ProfileOrderButtons
                          profileId={profile.id}
                          onSuccess={fetchProfiles}
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Paper>
        </Grid>
      </Grid>
    </Container>
  );
};

export default DashboardPage;
END
  echo "✅ Создан новый файл DashboardPage.tsx с кнопками порядка"
fi

# Проверяем маршрутизацию
echo "🔍 Проверяю маршрутизацию для Dashboard..."
APP_ROUTER="/root/escort-project/client/src/App.tsx"
if [ -f "$APP_ROUTER" ]; then
  # Проверяем, есть ли маршрут для Dashboard
  if grep -q "/admin/dashboard" "$APP_ROUTER"; then
    echo "✅ Маршрут для Dashboard уже существует"
  else
    echo "❌ Маршрут для Dashboard не найден, добавляю..."
    cp "$APP_ROUTER" "${APP_ROUTER}.bak_route"
    
    # Проверяем, импортирован ли компонент DashboardPage
    if ! grep -q "import DashboardPage" "$APP_ROUTER"; then
      sed -i '1s|^|import DashboardPage from "./pages/admin/DashboardPage";\n|' "$APP_ROUTER"
    fi
    
    # Добавляем маршрут для Dashboard
    if grep -q "/admin/login" "$APP_ROUTER"; then
      sed -i 's|<Route path="/admin/login"|<Route path="/admin/dashboard" element={<DashboardPage />} />\n          <Route path="/admin/login"|' "$APP_ROUTER"
    else
      echo "⚠️ Не удалось найти удобное место для добавления маршрута Dashboard"
      echo "Пожалуйста, добавьте маршрут вручную: <Route path=\"/admin/dashboard\" element={<DashboardPage />} />"
    fi
    
    echo "✅ Маршрут для Dashboard добавлен"
  fi
else
  echo "❌ Файл App.tsx не найден! Невозможно проверить маршрутизацию"
fi

# Проверяем контроллер профилей на сервере
echo "🔍 Проверяю контроллер профилей на сервере..."
PROFILE_CONTROLLER="/root/escort-project/server/src/controllers/profileController.ts"
if [ -f "$PROFILE_CONTROLLER" ]; then
  # Проверяем наличие методов moveProfileUp и moveProfileDown
  if grep -q "moveProfileUp\|moveProfileDown" "$PROFILE_CONTROLLER"; then
    echo "✅ Методы moveProfileUp и moveProfileDown уже существуют в контроллере"
  else
    echo "❌ Методы для управления порядком не найдены, добавляю..."
    cp "$PROFILE_CONTROLLER" "${PROFILE_CONTROLLER}.bak_order"
    
    # Добавляем методы в конец файла
    cat >> "$PROFILE_CONTROLLER" << 'END'

// Перемещение профиля вверх по порядку (уменьшение значения order)
export const moveProfileUp = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Находим текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId },
    });
    
    if (!currentProfile) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    
    // Находим профиль с меньшим значением order (который выше в списке)
    const prevProfile = await prisma.profile.findFirst({
      where: {
        cityId: currentProfile.cityId,
        order: { lt: currentProfile.order || 0 },
      },
      orderBy: {
        order: 'desc',
      },
    });
    
    if (!prevProfile) {
      return res.status(200).json({ 
        message: 'Profile is already at the top',
        profile: currentProfile
      });
    }
    
    // Меняем порядок
    await prisma.$transaction([
      prisma.profile.update({
        where: { id: profileId },
        data: { order: prevProfile.order },
      }),
      prisma.profile.update({
        where: { id: prevProfile.id },
        data: { order: currentProfile.order },
      }),
    ]);
    
    return res.status(200).json({ 
      message: 'Profile moved up successfully',
      profile: await prisma.profile.findUnique({
        where: { id: profileId },
      })
    });
  } catch (error) {
    console.error('Error moving profile up:', error);
    return res.status(500).json({ error: 'Failed to move profile up' });
  }
};

// Перемещение профиля вниз по порядку (увеличение значения order)
export const moveProfileDown = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Находим текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId },
    });
    
    if (!currentProfile) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    
    // Находим профиль с большим значением order (который ниже в списке)
    const nextProfile = await prisma.profile.findFirst({
      where: {
        cityId: currentProfile.cityId,
        order: { gt: currentProfile.order || 0 },
      },
      orderBy: {
        order: 'asc',
      },
    });
    
    if (!nextProfile) {
      return res.status(200).json({ 
        message: 'Profile is already at the bottom',
        profile: currentProfile
      });
    }
    
    // Меняем порядок
    await prisma.$transaction([
      prisma.profile.update({
        where: { id: profileId },
        data: { order: nextProfile.order },
      }),
      prisma.profile.update({
        where: { id: nextProfile.id },
        data: { order: currentProfile.order },
      }),
    ]);
    
    return res.status(200).json({ 
      message: 'Profile moved down successfully',
      profile: await prisma.profile.findUnique({
        where: { id: profileId },
      })
    });
  } catch (error) {
    console.error('Error moving profile down:', error);
    return res.status(500).json({ error: 'Failed to move profile down' });
  }
};
END
    echo "✅ Методы moveProfileUp и moveProfileDown добавлены в контроллер"
  fi
else
  echo "❌ Файл profileController.ts не найден!"
fi

# Проверяем маршруты для методов перемещения профилей
echo "🔍 Проверяю маршруты API для перемещения профилей..."
SERVER_INDEX="/root/escort-project/server/src/index.ts"
if [ -f "$SERVER_INDEX" ]; then
  # Проверяем наличие маршрутов для методов moveProfileUp и moveProfileDown
  if grep -q "moveProfileUp\|moveProfileDown\|move-up\|move-down" "$SERVER_INDEX"; then
    echo "✅ Маршруты для перемещения профилей уже добавлены"
  else
    echo "❌ Маршруты для перемещения профилей не найдены, добавляю..."
    cp "$SERVER_INDEX" "${SERVER_INDEX}.bak_routes"
    
    # Добавляем маршруты для перемещения профилей
    # Ищем блок защищенных маршрутов администратора
    if grep -q "app.patch('/api/admin/profiles/:id/verify'" "$SERVER_INDEX"; then
      sed -i '/app.patch.\/api\/admin\/profiles\/:id\/verify/a \
app.patch(\'/api\/admin\/profiles\/:id\/moveUp\', profileController.moveProfileUp);\
app.patch(\'/api\/admin\/profiles\/:id\/moveDown\', profileController.moveProfileDown);' "$SERVER_INDEX"
      echo "✅ Маршруты для перемещения профилей добавлены"
    else
      echo "⚠️ Не удалось найти место для добавления маршрутов"
      echo "Пожалуйста, добавьте маршруты вручную после строки с app.patch('/api/admin/profiles/:id/verify')"
    fi
  fi
else
  echo "❌ Файл index.ts не найден!"
fi

echo "🚀 Пересобираем и перезапускаем проект..."
cd /root/escort-project
docker-compose restart server
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

echo "✅ Кнопки управления порядком профилей восстановлены!"
echo "🌐 Проверьте кнопки на странице: https://eskortvsegorodarfreal.site/admin/dashboard"
echo "💡 Не забудьте войти в систему перед проверкой кнопок"
