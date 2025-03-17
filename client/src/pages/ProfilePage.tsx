import React, { useState, useEffect } from 'react';
import {
  Container,
  Grid,
  Typography,
  Box,
  Chip,
  Paper,
  CircularProgress,
  Alert,
  ImageList,
  ImageListItem,
  styled,
  Divider,
  Button,
  useTheme,
  useMediaQuery,
  Card,
  CardContent,
  Avatar,
  IconButton,
  Tabs,
  Tab,
  Fade,
  Dialog,
  DialogContent,
} from '@mui/material';
import {
  DirectionsCar as CarIcon,
  Home as HomeIcon,
  VerifiedUser as VerifiedIcon,
  AccessTime as TimeIcon,
  SmokingRooms as SmokingIcon,
  SmokeFree as NoSmokingIcon,
  Star as StarIcon,
  Group as GroupIcon,
  Person as PersonIcon,
  Phone as PhoneIcon,
  WhatsApp as WhatsAppIcon,
  Telegram as TelegramIcon,
  ArrowBack as ArrowBackIcon,
  Close as CloseIcon,
} from '@mui/icons-material';
import { useParams, useNavigate } from 'react-router-dom';
import { Profile, City, Language } from '../types';
import { api } from '../utils/api';
import { serviceTranslations } from '../utils/serviceTranslations';
import SEO from '../components/SEO/SEO';
import SchemaMarkup from '../components/SEO/SchemaMarkup';
import Header from '../components/Header';

// Определение типа PageContainer
const PageContainer = styled(Box)(({ theme }) => ({
  minHeight: '100vh',
  backgroundColor: theme.palette.background.default,
  paddingBottom: theme.spacing(4),
}));

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

const TabPanel = (props: TabPanelProps) => {
  const { children, value, index, ...other } = props;
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`profile-tabpanel-${index}`}
      aria-labelledby={`profile-tab-${index}`}
      {...other}
    >
      {value === index && (
        <Fade in={value === index}>
          <Box sx={{ p: 3 }}>{children}</Box>
        </Fade>
      )}
    </div>
  );
};

const StyledPaper = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(3),
  marginBottom: theme.spacing(3),
  borderRadius: theme.spacing(2),
  background: 'rgba(30, 30, 30, 0.95)',
  backdropFilter: 'blur(10px)',
}));

const ProfileImage = styled('img')({
  width: '100%',
  height: '100%',
  objectFit: 'cover',
  borderRadius: 8,
  cursor: 'pointer',
  transition: 'transform 0.3s ease',
  '&:hover': {
    transform: 'scale(1.02)',
  },
});

const IconChip = styled(Chip)(({ theme }) => ({
  margin: theme.spacing(0.5),
  borderRadius: theme.spacing(1),
  '& .MuiChip-icon': {
    color: 'inherit',
  },
}));

const PriceCard = styled(Card)(({ theme }) => ({
  background: theme.palette.primary.main,
  color: theme.palette.primary.contrastText,
  borderRadius: theme.spacing(2),
  position: 'relative',
  overflow: 'visible',
  '&::before': {
    content: '""',
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: 'linear-gradient(45deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0) 100%)',
    borderRadius: 'inherit',
  },
}));

const ContactButton = styled(Button)(({ theme }) => ({
  borderRadius: theme.spacing(1),
  padding: theme.spacing(1.5, 3),
  fontWeight: 'bold',
  fontSize: '1.1rem',
  textTransform: 'none',
  boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
  '&:hover': {
    transform: 'translateY(-2px)',
    boxShadow: '0 6px 8px rgba(0,0,0,0.2)',
  },
  transition: 'all 0.2s ease',
}));

const ProfilePage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [tabValue, setTabValue] = useState(0);
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  
  // Добавляем состояние для открытия/закрытия диалога для просмотра изображения
  const [imageDialogOpen, setImageDialogOpen] = useState(false);
  
  // Добавление состояний для Header
  const [cities, setCities] = useState<City[]>([]);
  const [selectedCity, setSelectedCity] = useState<City | null>(null);
  const [languages] = useState<Language[]>([
    { id: 1, code: 'ru', name: 'Русский' },
    { id: 2, code: 'en', name: 'English' }
  ]);
  const [selectedLanguage, setSelectedLanguage] = useState<Language>(languages[0]);

  useEffect(() => {
    const fetchCities = async () => {
      try {
        const response = await api.get('/cities');
        setCities(response.data);
        if (response.data.length > 0) {
          setSelectedCity(response.data[0]);
        }
      } catch (error) {
        console.error('Error fetching cities:', error);
      }
    };
    
    fetchCities();
  }, []);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.get(`/profiles/${id}`);
        setProfile(response.data);
      } catch (error) {
        console.error('Error fetching profile:', error);
        setError('Ошибка при загрузке анкеты');
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchProfile();
    }
  }, [id]);

  // Обработчики для показа/скрытия диалога с изображением
  const handleImageClick = (image: string) => {
    setSelectedImage(image);
    setImageDialogOpen(true);
  };

  const handleCloseImageDialog = () => {
    setImageDialogOpen(false);
  };

  const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
    setTabValue(newValue);
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '80vh' }}>
        <CircularProgress size={60} thickness={4} />
      </Box>
    );
  }

  if (error || !profile) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Alert severity="error">{error || 'Анкета не найдена'}</Alert>
      </Container>
    );
  }

  return (
    <PageContainer>
      {profile && (
        <>
          <SEO 
            title={`${profile.name}, ${profile.age} лет | Эскорт ${profile.city?.name || 'Москва'}`}
            description={`${profile.name}, ${profile.age} лет, ${profile.height} см, ${profile.weight} кг. ${profile.description.substring(0, 150)}...`}
            canonicalUrl={`https://eskortvsegorodarfreal.site/profile/${profile.id}`}
            ogImage={profile.photos && profile.photos.length > 0 ? profile.photos[0] : undefined}
            cityName={profile.city?.name}
          />
          <SchemaMarkup profile={profile} />
        </>
      )}
      
      <Header
        cities={cities}
        languages={languages}
        selectedCity={selectedCity}
        selectedLanguage={selectedLanguage}
        onCityChange={setSelectedCity}
        onLanguageChange={setSelectedLanguage}
      />
      
      <Container maxWidth="lg" sx={{ py: 4 }}>
        <Box sx={{ mb: 3 }}>
          <IconButton onClick={() => navigate(-1)} sx={{ mr: 2 }}>
            <ArrowBackIcon />
          </IconButton>
        </Box>

        <Grid container spacing={4}>
          <Grid item xs={12} md={8}>
            <StyledPaper elevation={3}>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                <Avatar
                  src={profile.photos[0]}
                  sx={{ width: 80, height: 80, mr: 2 }}
                />
                <Box>
                  <Typography variant="h4" component="h1" gutterBottom>
                    {profile.name}, {profile.age}
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 1 }}>
                    <Chip
                      icon={<VerifiedIcon />}
                      label={profile.isVerified ? "Проверено" : "Не проверено"}
                      color={profile.isVerified ? "success" : "default"}
                    />
                    {profile.isNew && (
                      <Chip
                        icon={<StarIcon />}
                        label="Новенькая"
                        color="primary"
                      />
                    )}
                  </Box>
                </Box>
              </Box>

              <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
                <Tabs
                  value={tabValue}
                  onChange={handleTabChange}
                  variant={isMobile ? "scrollable" : "fullWidth"}
                  scrollButtons={isMobile ? "auto" : false}
                >
                  <Tab label="Фото" />
                  <Tab label="Услуги" />
                  <Tab label="О себе" />
                </Tabs>
              </Box>

              <TabPanel value={tabValue} index={0}>
                <ImageList cols={isMobile ? 1 : 2} gap={16}>
                  {profile.photos.map((photo: string, index: number) => (
                    <ImageListItem key={index}>
                      <ProfileImage
                        src={photo}
                        alt={`${profile.name} - ${profile.age} лет, ${getPhotoDescription(index, profile)} | Проститутка ${profile.city?.name || 'Москва'}`}
                        loading="lazy"
                        onClick={() => handleImageClick(photo)}
                      />
                    </ImageListItem>
                  ))}
                </ImageList>
              </TabPanel>

              <TabPanel value={tabValue} index={1}>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                  {profile.services.map((service: string, index: number) => (
                    <Chip
                      key={index}
                      label={serviceTranslations[service] || service}
                      sx={{
                        backgroundColor: 'rgba(255, 107, 0, 0.1)',
                        color: theme.palette.primary.main,
                        '&:hover': {
                          backgroundColor: 'rgba(255, 107, 0, 0.2)',
                        },
                      }}
                    />
                  ))}
                </Box>
              </TabPanel>

              <TabPanel value={tabValue} index={2}>
                <Typography variant="body1" sx={{ whiteSpace: 'pre-line' }}>
                  {profile.description}
                </Typography>
              </TabPanel>
            </StyledPaper>
          </Grid>

          <Grid item xs={12} md={4}>
            <Box sx={{ position: 'sticky', top: 24 }}>
              <StyledPaper elevation={3}>
                <Typography variant="h6" gutterBottom>
                  Параметры
                </Typography>
                <Grid container spacing={2}>
                  <Grid item xs={6}>
                    <Typography color="text.secondary">Рост</Typography>
                    <Typography variant="h6">{profile.height} см</Typography>
                  </Grid>
                  <Grid item xs={6}>
                    <Typography color="text.secondary">Вес</Typography>
                    <Typography variant="h6">{profile.weight} кг</Typography>
                  </Grid>
                  <Grid item xs={6}>
                    <Typography color="text.secondary">Грудь</Typography>
                    <Typography variant="h6">{profile.breastSize}</Typography>
                  </Grid>
                  {profile.nationality && (
                    <Grid item xs={6}>
                      <Typography color="text.secondary">Национальность</Typography>
                      <Typography variant="h6">{profile.nationality}</Typography>
                    </Grid>
                  )}
                </Grid>

                <Divider sx={{ my: 3 }} />

                <Typography variant="h6" gutterBottom>
                  Цены
                </Typography>
                <Grid container spacing={2}>
                  {profile.priceExpress > 0 && (
                    <Grid item xs={12}>
                      <PriceCard>
                        <CardContent>
                          <Typography variant="subtitle2">Экспресс</Typography>
                          <Typography variant="h5">{profile.priceExpress}₽</Typography>
                        </CardContent>
                      </PriceCard>
                    </Grid>
                  )}
                  <Grid item xs={12}>
                    <PriceCard>
                      <CardContent>
                        <Typography variant="subtitle2">1 час</Typography>
                        <Typography variant="h5">{profile.price1Hour}₽</Typography>
                      </CardContent>
                    </PriceCard>
                  </Grid>
                  <Grid item xs={12}>
                    <PriceCard>
                      <CardContent>
                        <Typography variant="subtitle2">2 часа</Typography>
                        <Typography variant="h5">{profile.price2Hours}₽</Typography>
                      </CardContent>
                    </PriceCard>
                  </Grid>
                  <Grid item xs={12}>
                    <PriceCard>
                      <CardContent>
                        <Typography variant="subtitle2">Ночь</Typography>
                        <Typography variant="h5">{profile.priceNight}₽</Typography>
                      </CardContent>
                    </PriceCard>
                  </Grid>
                </Grid>

                <Box sx={{ mt: 3 }}>
                  <ContactButton
                    variant="contained"
                    fullWidth
                    startIcon={<PhoneIcon />}
                    sx={{ mb: 2 }}
                  >
                    Позвонить
                  </ContactButton>
                  <Box sx={{ display: 'flex', gap: 2 }}>
                    <ContactButton
                      variant="outlined"
                      fullWidth
                      startIcon={<WhatsAppIcon />}
                    >
                      WhatsApp
                    </ContactButton>
                    <ContactButton
                      variant="outlined"
                      fullWidth
                      startIcon={<TelegramIcon />}
                    >
                      Telegram
                    </ContactButton>
                  </Box>
                </Box>
              </StyledPaper>

              <StyledPaper elevation={3}>
                <Typography variant="h6" gutterBottom>
                  Дополнительно
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                  {profile.isNonSmoking ? (
                    <IconChip icon={<NoSmokingIcon />} label="Не курит" />
                  ) : (
                    <IconChip icon={<SmokingIcon />} label="Курит" />
                  )}
                  {profile.is24Hours && <IconChip icon={<TimeIcon />} label="24 часа" />}
                  {profile.isAlone ? (
                    <IconChip icon={<PersonIcon />} label="Одна" />
                  ) : (
                    <IconChip icon={<GroupIcon />} label="С подругами" />
                  )}
                  {profile.inCall && <IconChip icon={<HomeIcon />} label="Принимает у себя" />}
                  {profile.outCall && <IconChip icon={<CarIcon />} label="Выезжает" />}
                </Box>
              </StyledPaper>
            </Box>
          </Grid>
        </Grid>
      </Container>
      
      {/* Диалог для просмотра выбранного изображения */}
      <Dialog
        open={imageDialogOpen}
        onClose={handleCloseImageDialog}
        maxWidth="lg"
        fullScreen={isMobile}
      >
        <DialogContent sx={{ p: 0, position: 'relative' }}>
          <IconButton
            aria-label="close"
            onClick={handleCloseImageDialog}
            sx={{
              position: 'absolute',
              right: 8,
              top: 8,
              backgroundColor: 'rgba(0, 0, 0, 0.5)',
              '&:hover': {
                backgroundColor: 'rgba(0, 0, 0, 0.7)',
              },
              zIndex: 10,
            }}
          >
            <CloseIcon sx={{ color: 'white' }} />
          </IconButton>
          {selectedImage && (
            <img
              src={selectedImage}
              alt={`${profile.name} - фото в полный размер`}
              style={{
                width: '100%',
                maxHeight: '90vh',
                objectFit: 'contain',
              }}
            />
          )}
        </DialogContent>
      </Dialog>
    </PageContainer>
  );
};

// Добавляем функцию для генерации разнообразных описаний фото
const getPhotoDescription = (index: number, profile: Profile): string => {
  const descriptions = [
    `элитная эскорт модель ${profile.height}см/${profile.weight}кг`,
    `индивидуалка с грудью ${profile.breastSize} размера`,
    `стройная VIP проститутка, оказывает эскорт услуги`,
    `интимные услуги от красивой девушки`,
    `лучшие интим услуги в ${profile.city?.name || 'Москве'}`,
    `шикарная девушка для приятного времяпровождения`,
    `приглашает на интим встречу`,
    `опытная индивидуалка для VIP клиентов`,
    `шикарная фигура, приглашает в гости`,
    `эротическое фото, доступны разные услуги`
  ];
  
  // Используем индекс фото для выбора описания, чтобы разные фото имели разные описания
  return descriptions[index % descriptions.length];
};

export default ProfilePage; 