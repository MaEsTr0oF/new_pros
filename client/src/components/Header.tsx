import React from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  Box,
  Select,
  MenuItem,
  Button,
  styled,
  SelectChangeEvent,
  useMediaQuery,
  useTheme,
} from '@mui/material';
import { Add as AddIcon, Language } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { City, Language as LanguageType } from '../types';

const StyledAppBar = styled(AppBar)(({ theme }) => ({
  backgroundColor: theme.palette.primary.main,
  boxShadow: 'none',
}));

const GridToolbar = styled(Toolbar)(({ theme }) => ({
  display: 'grid',
  gridTemplateColumns: '1fr auto',
  gap: theme.spacing(2),
  padding: theme.spacing(2, 2),
  [theme.breakpoints.down('sm')]: {
    gridTemplateColumns: '1fr',
    padding: theme.spacing(1, 1),
    gap: theme.spacing(1),
  },
}));

const ControlsContainer = styled(Box)(({ theme }) => ({
  display: 'grid',
  gridTemplateColumns: 'repeat(3, minmax(0, 1fr))',
  gap: theme.spacing(1),
  alignItems: 'center',
  [theme.breakpoints.down('md')]: {
    gridTemplateColumns: 'repeat(3, minmax(0, 1fr))',
  },
  [theme.breakpoints.down('sm')]: {
    gridTemplateColumns: 'repeat(2, 1fr)',
    gridTemplateRows: 'auto auto',
    '& > *:nth-of-type(3)': {
      gridColumn: '1 / -1',
    },
  },
}));

const StyledSelect = styled(Select)(({ theme }) => ({
  backgroundColor: 'rgba(255, 255, 255, 0.1)',
  color: 'white',
  '& .MuiSelect-icon': {
    color: 'white',
  },
  '& .MuiOutlinedInput-notchedOutline': {
    border: '1px solid rgba(255, 255, 255, 0.3)',
  },
  '&:hover .MuiOutlinedInput-notchedOutline': {
    border: '1px solid rgba(255, 255, 255, 0.5)',
  },
  '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
    border: '1px solid rgba(255, 255, 255, 0.7)',
  },
  minWidth: 120,
  height: 40,
  width: '100%',
  [theme.breakpoints.down('sm')]: {
    height: 36,
    '& .MuiSelect-select': {
      padding: '8px 32px 8px 12px',
      fontSize: '0.875rem',
    },
  },
}));

const AddButton = styled(Button)(({ theme }) => ({
  backgroundColor: theme.palette.info.main,
  color: 'white',
  '&:hover': {
    backgroundColor: theme.palette.info.dark,
  },
  height: 40,
  width: '100%',
  [theme.breakpoints.down('sm')]: {
    height: 36,
    fontSize: '0.875rem',
  },
}));

interface HeaderProps {
  cities: City[];
  languages: LanguageType[];
  selectedCity: City | null;
  selectedLanguage: LanguageType;
  onCityChange: (city: City) => void;
  onLanguageChange: (language: LanguageType) => void;
}

const Header: React.FC<HeaderProps> = ({
  cities,
  languages,
  selectedCity,
  selectedLanguage,
  onCityChange,
  onLanguageChange,
}) => {
  const navigate = useNavigate();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  const handleCityChange = (event: SelectChangeEvent<unknown>) => {
    const city = cities.find(c => c.id === Number(event.target.value));
    if (city) {
      onCityChange(city);
    }
  };

  const handleLanguageChange = (event: SelectChangeEvent<unknown>) => {
    const language = languages.find(l => l.id === Number(event.target.value));
    if (language) {
      onLanguageChange(language);
    }
  };

  return (
    <StyledAppBar position="sticky">
      <GridToolbar>
        <Typography
          variant={isMobile ? "body1" : "h6"}
          component="div"
          sx={{
            fontWeight: 'bold',
            cursor: 'pointer',
            textAlign: isMobile ? 'center' : 'left',
          }}
          onClick={() => navigate('/')}
        >
          Проститутки {selectedCity?.name || ''}
        </Typography>

        <ControlsContainer>
          <StyledSelect
            value={selectedCity?.id || ''}
            onChange={handleCityChange}
            displayEmpty
            renderValue={(value) => {
              if (!value) return 'Выберите город';
              const city = cities.find(c => c.id === value);
              return city?.name || '';
            }}
          >
            {cities.map((city) => (
              <MenuItem key={city.id} value={city.id}>
                {city.name}
              </MenuItem>
            ))}
          </StyledSelect>

          <StyledSelect
            value={selectedLanguage.id}
            onChange={handleLanguageChange}
            IconComponent={() => <Language sx={{ color: 'white', mr: 1 }} />}
          >
            {languages.map((language) => (
              <MenuItem key={language.id} value={language.id}>
                {language.name}
              </MenuItem>
            ))}
          </StyledSelect>

          <AddButton
            variant="contained"
            startIcon={<AddIcon />}
            onClick={() => navigate('/add-profile')}
          >
            {isMobile ? 'Добавить' : 'Добавить анкету'}
          </AddButton>
        </ControlsContainer>
      </GridToolbar>
    </StyledAppBar>
  );
};

export default Header; 