import React, { useState, useEffect } from 'react';
import {
  Container,
  Grid,
  CircularProgress,
  Box,
  Alert,
  Typography,
  Paper,
  styled,
  useMediaQuery,
  useTheme,
} from '@mui/material';
import Header from '../components/Header';
import FilterBar from '../components/FilterBar';
import ProfileCard from '../components/ProfileCard';
import CommonSEO from '../components/SEO/CommonSEO';
import { Profile, City, Language, FilterParams } from '../types';
import axios from 'axios';
import { API_URL } from '../config';

const PageContainer = styled(Box)(({ theme }) => ({
  minHeight: '100vh',
  backgroundColor: theme.palette.background.default,
  paddingBottom: theme.spacing(4),
  [theme.breakpoints.down('sm')]: {
    paddingBottom: theme.spacing(2),
  },
}));

const ContentContainer = styled(Container)(({ theme }) => ({
  paddingTop: theme.spacing(3),
  paddingBottom: theme.spacing(4),
  [theme.breakpoints.down('sm')]: {
    paddingTop: theme.spacing(2),
    paddingBottom: theme.spacing(2),
  },
}));

const ProfilesGrid = styled(Box)(({ theme }) => ({
  display: 'grid',
  gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
  gap: theme.spacing(3),
  margin: theme.spacing(3, 0),
  [theme.breakpoints.down('md')]: {
    gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))',
    gap: theme.spacing(2),
  },
  [theme.breakpoints.down('sm')]: {
    gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))',
    gap: theme.spacing(1.5),
    margin: theme.spacing(2, 0),
  },
  [theme.breakpoints.down('xs')]: {
    gridTemplateColumns: '1fr',
    gap: theme.spacing(1),
    margin: theme.spacing(1.5, 0),
  },
}));

const LoadingContainer = styled(Box)(({ theme }) => ({
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center',
  height: '50vh',
  flexDirection: 'column',
  gap: theme.spacing(2),
  [theme.breakpoints.down('sm')]: {
    height: '40vh',
    gap: theme.spacing(1),
  },
}));

const StyledAlert = styled(Alert)(({ theme }) => ({
  marginBottom: theme.spacing(2),
  borderRadius: theme.shape.borderRadius,
  [theme.breakpoints.down('sm')]: {
    marginBottom: theme.spacing(1),
    '& .MuiAlert-message': {
      fontSize: '0.875rem',
    },
  },
}));

const WelcomeSection = styled(Box)(({ theme }) => ({
  marginBottom: theme.spacing(4),
  textAlign: 'center',
  padding: theme.spacing(2),
  display: 'grid',
  gap: theme.spacing(2),
  [theme.breakpoints.down('sm')]: {
    marginBottom: theme.spacing(2),
    padding: theme.spacing(1),
    gap: theme.spacing(1),
  },
}));

const initialFilters: FilterParams = {
  gender: [],
  appearance: {
    age: [18, 70],
    height: [140, 195],
    weight: [40, 110],
    breastSize: [1, 10],
    nationality: [],
    hairColor: [],
    bikiniZone: [],
  },
  district: [],
  price: {
    from: null,
    to: null,
    hasExpress: false
  },
  services: [],
  verification: [],
  other: [],
  outcall: false
};

const HomePage: React.FC = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isXSmall = useMediaQuery(theme.breakpoints.down('xs'));
  
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [selectedCity, setSelectedCity] = useState<City | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [languages] = useState<Language[]>([
    { id: 1, code: 'ru', name: 'Русский' },
    { id: 2, code: 'en', name: 'English' }
  ]);
  const [selectedLanguage, setSelectedLanguage] = useState<Language>(languages[0]);
  const [filters, setFilters] = useState<FilterParams>(initialFilters);
  const [districts, setDistricts] = useState<string[]>([]);
  const [services, setServices] = useState<string[]>([]);

  useEffect(() => {
    // Загрузка городов
    const fetchCities = async () => {
      try {
        const response = await axios.get(`${API_URL}/cities`);
        setCities(response.data);
        if (response.data.length > 0) {
          setSelectedCity(response.data[0]);
        }
      } catch (error) {
        console.error('Ошибка при загрузке городов:', error);
        setError('Ошибка при загрузке городов');
      }
    };

    fetchCities();
  }, []);

  useEffect(() => {
    // Загрузка анкет
    const fetchProfiles = async () => {
      setLoading(true);
      setError('');
      
      try {
        const params = {
          ...(selectedCity && { cityId: selectedCity.id }),
          filters: JSON.stringify(filters)
        };

        const response = await axios.get(`${API_URL}/profiles`, { params });
        setProfiles(response.data);
      } catch (error) {
        console.error('Ошибка при загрузке анкет:', error);
        setError('Ошибка при загрузке анкет');
      } finally {
        setLoading(false);
      }
    };

    fetchProfiles();
  }, [selectedCity, filters]);

  useEffect(() => {
    // Загрузка справочников для фильтров
    const fetchFilterData = async () => {
      if (!selectedCity) return;
      
      try {
        const [districtsResponse, servicesResponse] = await Promise.all([
          axios.get(`${API_URL}/districts/${selectedCity.id}`),
          axios.get(`${API_URL}/services`)
        ]);
        
        setDistricts(districtsResponse.data);
        setServices(servicesResponse.data);
      } catch (error) {
        console.error('Ошибка при загрузке данных для фильтров:', error);
      }
    };

    fetchFilterData();
  }, [selectedCity]);

  const renderContent = () => {
    if (loading) {
      return (
        <LoadingContainer>
          <CircularProgress size={isMobile ? 40 : 60} />
          <Typography 
            variant={isMobile ? "body2" : "h6"} 
            color="text.secondary"
            sx={{ textAlign: 'center' }}
          >
            Загрузка анкет...
          </Typography>
        </LoadingContainer>
      );
    }

    if (error) {
      return (
        <StyledAlert severity="error">
          {error}
        </StyledAlert>
      );
    }

    if (profiles.length === 0) {
      return (
        <StyledAlert severity="info">
          По вашему запросу ничего не найдено
        </StyledAlert>
      );
    }

    return (
      <ProfilesGrid>
        {profiles.map((profile) => (
          <ProfileCard key={profile.id} profile={profile} />
        ))}
      </ProfilesGrid>
    );
  };

  return (
    <PageContainer>
      <CommonSEO 
        cityName={selectedCity?.name} 
        isHomePage={true}
      />
      <Header
        cities={cities}
        languages={languages}
        selectedCity={selectedCity}
        selectedLanguage={selectedLanguage}
        onCityChange={setSelectedCity}
        onLanguageChange={setSelectedLanguage}
      />
      <ContentContainer maxWidth="lg">
        <WelcomeSection>
          <Typography 
            variant={isMobile ? "h6" : "h4"} 
            component="h1" 
            gutterBottom 
            sx={{ 
              fontWeight: 'bold', 
              color: 'primary.main',
              marginBottom: 0,
              [theme.breakpoints.down('sm')]: {
                fontSize: '1.5rem',
                lineHeight: 1.2,
              },
            }}
          >
            Проститутки России | VIP Эскорт услуги
          </Typography>
          <Typography 
            variant={isMobile ? "body2" : "body1"} 
            color="text.secondary"
            sx={{ 
              maxWidth: '800px', 
              margin: '0 auto',
              [theme.breakpoints.down('sm')]: {
                fontSize: '0.875rem',
                lineHeight: 1.4,
              },
            }}
          >
            На нашем сайте представлены элитные проститутки и индивидуалки из 50 городов России. 
            Все анкеты с проверенными фото девушек, предоставляющих VIP эскорт услуги. 
            Выберите город и найдите подходящую девушку для приятного времяпрепровождения.
          </Typography>
        </WelcomeSection>
        
        <FilterBar
          filters={filters}
          onFilterChange={setFilters}
          districts={districts}
        />
        {renderContent()}
      </ContentContainer>
    </PageContainer>
  );
};

export default HomePage; 