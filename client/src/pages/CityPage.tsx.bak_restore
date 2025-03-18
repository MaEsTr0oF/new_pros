import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import {
  Box,
  Container,
  Grid,
  Typography,
  CircularProgress,
  Alert,
  styled,
  Breadcrumbs,
  Link as MuiLink,
} from '@mui/material';
import { API_URL } from '../config';
import CommonSEO from '../components/SEO/CommonSEO';
import ProfileCard from '../components/ProfileCard';
import Header from '../components/Header';
import FilterBar from '../components/FilterBar';
import { City, Profile, Language, FilterParams } from '../types';

const PageContainer = styled(Box)(({ theme }) => ({
  minHeight: '100vh',
  backgroundColor: theme.palette.background.default,
}));

const ContentContainer = styled(Container)(({ theme }) => ({
  paddingTop: theme.spacing(3),
  paddingBottom: theme.spacing(6),
}));

const LoadingContainer = styled(Box)(({ theme }) => ({
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  justifyContent: 'center',
  minHeight: '50vh',
  gap: theme.spacing(2),
}));

const StyledAlert = styled(Alert)(({ theme }) => ({
  marginBottom: theme.spacing(3),
}));

const BreadcrumbsContainer = styled(Box)(({ theme }) => ({
  marginBottom: theme.spacing(3),
}));

const initialFilters: FilterParams = {
  gender: [],
  appearance: {
    age: [18, 45],
    height: [150, 190],
    weight: [40, 80],
    breastSize: [1, 10],
    nationality: [],
    hairColor: [],
    bikiniZone: [],
  },
  district: [],
  price: {
    from: 3000,
    to: 25000,
    hasExpress: false
  },
  services: [],
  verification: [],
  other: [],
  outcall: false
};

const CityPage: React.FC = () => {
  const { citySlug } = useParams<{ citySlug: string }>();
  const navigate = useNavigate();
  
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

  // Загрузка городов и поиск текущего города по URL
  useEffect(() => {
    const fetchCities = async () => {
      try {
        const response = await axios.get(`${API_URL}/cities`);
        setCities(response.data);
        
        if (citySlug && response.data.length > 0) {
          // Находим город по слагу URL
          const city = response.data.find((c: City) => 
            c.name.toLowerCase().replace(/\s+/g, '-') === citySlug
          );
          
          if (city) {
            setSelectedCity(city);
          } else {
            setError('Город не найден');
            navigate('/');
          }
        }
      } catch (error) {
        console.error('Ошибка при загрузке городов:', error);
        setError('Ошибка при загрузке городов');
      }
    };

    fetchCities();
  }, [citySlug, navigate]);

  // Загрузка анкет по выбранному городу
  useEffect(() => {
    if (!selectedCity) return;
    
    const fetchProfiles = async () => {
      setLoading(true);
      setError('');
      
      try {
        const params = {
          cityId: selectedCity.id,
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

  // Загрузка справочников для фильтров
  useEffect(() => {
    if (!selectedCity) return;
    
    const fetchFilterData = async () => {
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

  const handleCityChange = (city: City) => {
    const cityUrlSlug = city.name.toLowerCase().replace(/\s+/g, '-');
    navigate(`/${cityUrlSlug}`);
  };

  const renderContent = () => {
    if (loading) {
      return (
        <LoadingContainer>
          <CircularProgress size={60} />
          <Typography variant="h6" color="text.secondary">
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
      <Grid container spacing={3}>
        {profiles.map((profile) => (
          <Grid item xs={12} sm={6} md={4} key={profile.id}>
            <ProfileCard profile={profile} />
          </Grid>
        ))}
      </Grid>
    );
  };

  return (
    <PageContainer>
      {selectedCity && (
        <CommonSEO 
          cityName={selectedCity.name} 
          isHomePage={false}
        />
      )}
      <Header
        cities={cities}
        languages={languages}
        selectedCity={selectedCity}
        selectedLanguage={selectedLanguage}
        onCityChange={handleCityChange}
        onLanguageChange={setSelectedLanguage}
      />
      <ContentContainer maxWidth="lg">
        {selectedCity && (
          <BreadcrumbsContainer>
            <Breadcrumbs aria-label="breadcrumb">
              <MuiLink 
                color="inherit" 
                href="/"
                onClick={(e) => {
                  e.preventDefault();
                  navigate('/');
                }}
              >
                Главная
              </MuiLink>
              <Typography color="text.primary">{selectedCity.name}</Typography>
            </Breadcrumbs>
            
            <Typography variant="h4" component="h1" mt={2} mb={3}>
              Проститутки {selectedCity.name} | Эскорт услуги
            </Typography>
            <Typography variant="body1" mb={3} color="text.secondary">
              Элитные проститутки {selectedCity.name}. На этой странице представлены VIP девушки с реальными фото, проверенные администрацией сайта. 
              Индивидуалки {selectedCity.name} с высоким уровнем сервиса и гарантией конфиденциальности.
            </Typography>
          </BreadcrumbsContainer>
        )}
        
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

export default CityPage; 