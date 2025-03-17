import '../styles/filter-styles.css';
import React from 'react';
import {
  Box,
  Button,
  MenuItem,
  Select,
  SelectChangeEvent,
  styled,
  Popover,
  FormControlLabel,
  Checkbox,
  Typography,
  Divider,
  Slider,
  TextField,
  useTheme,
  useMediaQuery,
} from '@mui/material';
import {
  KeyboardArrowDown as ArrowDownIcon,
} from '@mui/icons-material';
import { FilterParams, Service, SERVICE_OPTIONS } from '../types';
import { serviceTranslations } from '../utils/serviceTranslations';

const FilterContainer = styled(Box)(({ theme }) => ({
  padding: theme.spacing(1.5),
  display: 'grid',
  gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))',
  gap: theme.spacing(1.5),
  backgroundColor: theme.palette.background.paper,
  borderRadius: 0,
  borderBottom: `1px solid ${theme.palette.divider}`,
  [theme.breakpoints.down('md')]: {
    gridTemplateColumns: 'repeat(auto-fill, minmax(120px, 1fr))',
    padding: theme.spacing(1),
    gap: theme.spacing(1),
  },
  [theme.breakpoints.down('sm')]: {
    gridTemplateColumns: 'repeat(auto-fill, minmax(100px, 1fr))',
    padding: theme.spacing(0.75),
    gap: theme.spacing(0.75),
  },
  [theme.breakpoints.down('xs')]: {
    gridTemplateColumns: 'repeat(2, 1fr)',
    padding: theme.spacing(0.5),
    gap: theme.spacing(0.5),
  },
}));

const FilterSection = styled(Box)(({ theme }) => ({
  display: 'grid',
  gridTemplateColumns: '1fr',
  gap: theme.spacing(1),
  [theme.breakpoints.down('sm')]: {
    gap: theme.spacing(0.5),
  },
}));

const FilterButtonsGrid = styled(Box)(({ theme }) => ({
  display: 'grid',
  gridTemplateColumns: 'repeat(auto-fill, minmax(100px, 1fr))',
  gap: theme.spacing(1),
  margin: theme.spacing(0, 0, 1, 0),
  [theme.breakpoints.down('md')]: {
    gridTemplateColumns: 'repeat(auto-fill, minmax(90px, 1fr))',
  },
  [theme.breakpoints.down('sm')]: {
    gridTemplateColumns: 'repeat(auto-fill, minmax(80px, 1fr))',
    gap: theme.spacing(0.5),
  },
}));

const StyledSelect = styled(Select)(({ theme }) => ({
  backgroundColor: theme.palette.background.default,
  color: theme.palette.text.primary,
  '& .MuiSelect-select': {
    padding: '8px 32px 8px 12px',
    [theme.breakpoints.down('sm')]: {
      padding: '6px 24px 6px 8px',
      fontSize: '0.875rem',
    },
    [theme.breakpoints.down('xs')]: {
      padding: '4px 20px 4px 6px',
      fontSize: '0.75rem',
    },
  },
  '& .MuiOutlinedInput-notchedOutline': {
    border: 'none',
  },
  '& .MuiSvgIcon-root': {
    color: theme.palette.text.primary,
    [theme.breakpoints.down('sm')]: {
      fontSize: '1.25rem',
    },
  },
  '&:hover': {
    backgroundColor: theme.palette.action.hover,
  },
  '& .MuiMenu-paper': {
    backgroundColor: theme.palette.background.paper,
  },
  width: '100%',
}));

const ActionButton = styled(Button)(({ theme }) => ({
  backgroundColor: theme.palette.background.default,
  color: theme.palette.text.primary,
  '&:hover': {
    backgroundColor: theme.palette.action.hover,
  },
  textTransform: 'none',
  boxShadow: 'none',
  width: '100%',
  height: '40px',
  [theme.breakpoints.down('sm')]: {
    height: '36px',
    fontSize: '0.875rem',
    padding: '6px 8px',
  },
  [theme.breakpoints.down('xs')]: {
    height: '32px',
    fontSize: '0.75rem',
    padding: '4px 6px',
  },
}));

const PopoverContent = styled(Box)(({ theme }) => ({
  padding: theme.spacing(2),
  [theme.breakpoints.down('sm')]: {
    padding: theme.spacing(1.5),
  },
  [theme.breakpoints.down('xs')]: {
    padding: theme.spacing(1),
  },
  maxWidth: '300px',
  width: '100%',
  maxHeight: '80vh',
  overflow: 'auto',
}));

const FilterPopover = styled(Popover)(({ theme }) => ({
  '& .MuiPopover-paper': {
    backgroundColor: theme.palette.background.paper,
    marginTop: '8px',
    minWidth: '300px',
    maxHeight: '80vh',
    padding: theme.spacing(2),
    [theme.breakpoints.down('sm')]: {
      minWidth: '280px',
      padding: theme.spacing(1.5),
    },
  },
}));

const ApplyButton = styled(Button)(({ theme }) => ({
  backgroundColor: theme.palette.primary.main,
  color: 'white',
  '&:hover': {
    backgroundColor: theme.palette.primary.dark,
  },
  marginTop: theme.spacing(2),
  width: '100%',
  [theme.breakpoints.down('sm')]: {
    marginTop: theme.spacing(1.5),
    height: '36px',
    fontSize: '0.875rem',
  },
}));

const CollapseButton = styled(Button)(({ theme }) => ({
  color: theme.palette.primary.main,
  '&:hover': {
    backgroundColor: 'transparent',
    textDecoration: 'underline',
  },
  padding: 0,
  marginTop: theme.spacing(1),
}));

const RangeContainer = styled(Box)(({ theme }) => ({
  padding: theme.spacing(1, 2),
  [theme.breakpoints.down('sm')]: {
    padding: theme.spacing(0.5, 1),
  },
  '& .MuiTypography-caption': {
    color: theme.palette.text.secondary,
    [theme.breakpoints.down('sm')]: {
      fontSize: '0.75rem',
    },
  },
}));

const StyledTextField = styled(TextField)(({ theme }) => ({
  '& .MuiOutlinedInput-root': {
    backgroundColor: theme.palette.background.default,
    '& fieldset': {
      border: 'none',
    },
    '&:hover fieldset': {
      border: 'none',
    },
    '&.Mui-focused fieldset': {
      border: 'none',
    },
  },
  '& input': {
    padding: '8px 12px',
    width: '100px',
    [theme.breakpoints.down('sm')]: {
      padding: '6px 8px',
      width: '80px',
      fontSize: '0.875rem',
    },
  },
}));

interface FilterBarProps {
  filters: FilterParams;
  districts: string[];
  onFilterChange: (filters: FilterParams) => void;
}

const FilterBar: React.FC<FilterBarProps> = ({ filters, districts = [], onFilterChange }) => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isXSmall = useMediaQuery(theme.breakpoints.down('xs'));

  const [localFilters, setLocalFilters] = React.useState(filters);

  const [genderAnchorEl, setGenderAnchorEl] = React.useState<null | HTMLElement>(null);
  const [tempGenderFilters, setTempGenderFilters] = React.useState<string[]>([]);

  const handleGenderClick = (event: React.MouseEvent<HTMLElement>) => {
    setGenderAnchorEl(event.currentTarget);
    setTempGenderFilters([...filters.gender]);
  };

  const handleGenderClose = () => {
    setGenderAnchorEl(null);
  };

  const handleGenderChange = (value: string) => {
    const currentIndex = tempGenderFilters.indexOf(value);
    const newChecked = [...tempGenderFilters];

    if (currentIndex === -1) {
      newChecked.push(value);
    } else {
      newChecked.splice(currentIndex, 1);
    }

    setTempGenderFilters(newChecked);
  };

  const handleGenderApply = () => {
    const newFilters = {
      ...filters,
      gender: tempGenderFilters,
    };
    setLocalFilters(newFilters);
    onFilterChange(newFilters);
    handleGenderClose();
  };

  const handleFilterChange = (field: string) => (event: SelectChangeEvent) => {
    const newFilters = {
      ...filters,
      [field]: event.target.value,
    };
    setLocalFilters(newFilters);
    onFilterChange(newFilters);
  };

  const handleReset = () => {
    const resetFilters: FilterParams = {
      gender: [],
      appearance: {
        age: [18, 70] as [number, number],
        height: [140, 195] as [number, number],
        weight: [40, 110] as [number, number],
        breastSize: [1, 10] as [number, number],
        nationality: [],
        hairColor: [],
        bikiniZone: [],
      },
      district: [],
      price: {
        from: null,
        to: null,
        hasExpress: false,
      },
      services: [],
      verification: [],
      other: [],
      outcall: false,
    };
    setLocalFilters(resetFilters);
    onFilterChange(resetFilters);
  };

  const IconComponent = () => <ArrowDownIcon />;

  const genderOpen = Boolean(genderAnchorEl);

  const [appearanceAnchorEl, setAppearanceAnchorEl] = React.useState<null | HTMLElement>(null);
  const [tempAppearanceFilters, setTempAppearanceFilters] = React.useState(filters.appearance);

  const handleAppearanceClick = (event: React.MouseEvent<HTMLElement>) => {
    setAppearanceAnchorEl(event.currentTarget);
    setTempAppearanceFilters({...filters.appearance});
  };

  const handleAppearanceClose = () => {
    setAppearanceAnchorEl(null);
  };

  const handleAppearanceApply = () => {
    const newFilters = {
      ...filters,
      appearance: tempAppearanceFilters,
    };
    setLocalFilters(newFilters);
    onFilterChange(newFilters);
    handleAppearanceClose();
  };

  const handleRangeChange = (field: keyof typeof tempAppearanceFilters) => 
    (event: Event, newValue: number | number[]) => {
      setTempAppearanceFilters({
        ...tempAppearanceFilters,
        [field]: newValue,
      });
  };

  const handleCheckboxChange = (field: keyof typeof tempAppearanceFilters, value: string) => {
    const currentArray = tempAppearanceFilters[field] as string[];
    const currentIndex = currentArray.indexOf(value);
    const newArray = [...currentArray];

    if (currentIndex === -1) {
      newArray.push(value);
    } else {
      newArray.splice(currentIndex, 1);
    }

    setTempAppearanceFilters({
      ...tempAppearanceFilters,
      [field]: newArray,
    });
  };

  const appearanceOpen = Boolean(appearanceAnchorEl);

  const [districtAnchorEl, setDistrictAnchorEl] = React.useState<null | HTMLElement>(null);
  const [tempDistrictFilters, setTempDistrictFilters] = React.useState<string[]>([]);

  const handleDistrictClick = (event: React.MouseEvent<HTMLElement>) => {
    setDistrictAnchorEl(event.currentTarget);
    setTempDistrictFilters([...filters.district]);
  };

  const handleDistrictClose = () => {
    setDistrictAnchorEl(null);
  };

  const handleDistrictChange = (value: string) => {
    const currentIndex = tempDistrictFilters.indexOf(value);
    const newChecked = [...tempDistrictFilters];

    if (currentIndex === -1) {
      newChecked.push(value);
    } else {
      newChecked.splice(currentIndex, 1);
    }

    setTempDistrictFilters(newChecked);
  };

  const handleDistrictApply = () => {
    const newFilters = {
      ...filters,
      district: tempDistrictFilters,
    };
    setLocalFilters(newFilters);
    onFilterChange(newFilters);
    handleDistrictClose();
  };

  const districtOpen = Boolean(districtAnchorEl);

  const [servicesAnchorEl, setServicesAnchorEl] = React.useState<null | HTMLElement>(null);
  const [tempServicesFilters, setTempServicesFilters] = React.useState<Service[]>(filters.services as Service[]);

  const handleServicesClick = (event: React.MouseEvent<HTMLElement>) => {
    setServicesAnchorEl(event.currentTarget);
    setTempServicesFilters([...filters.services] as Service[]);
  };

  const handleServicesClose = () => {
    setServicesAnchorEl(null);
  };

  const handleServicesChange = (value: Service) => {
    const currentIndex = tempServicesFilters.indexOf(value);
    const newChecked = [...tempServicesFilters];

    if (currentIndex === -1) {
      newChecked.push(value);
    } else {
      newChecked.splice(currentIndex, 1);
    }

    setTempServicesFilters(newChecked);
  };

  const handleServicesApply = () => {
    const newFilters = {
      ...filters,
      services: tempServicesFilters,
    };
    setLocalFilters(newFilters);
    onFilterChange(newFilters);
  };

  const servicesOpen = Boolean(servicesAnchorEl);

  const [verificationAnchorEl, setVerificationAnchorEl] = React.useState<null | HTMLElement>(null);
  const [tempVerificationFilters, setTempVerificationFilters] = React.useState<string[]>([]);

  const handleVerificationClick = (event: React.MouseEvent<HTMLElement>) => {
    setVerificationAnchorEl(event.currentTarget);
    setTempVerificationFilters([...filters.verification]);
  };

  const handleVerificationClose = () => {
    setVerificationAnchorEl(null);
  };

  const handleVerificationChange = (value: string) => {
    const currentIndex = tempVerificationFilters.indexOf(value);
    const newChecked = [...tempVerificationFilters];

    if (currentIndex === -1) {
      newChecked.push(value);
    } else {
      newChecked.splice(currentIndex, 1);
    }

    setTempVerificationFilters(newChecked);
  };

  const handleVerificationApply = () => {
    const newFilters = {
      ...filters,
      verification: tempVerificationFilters,
    };
    setLocalFilters(newFilters);
    onFilterChange(newFilters);
    handleVerificationClose();
  };

  const verificationOpen = Boolean(verificationAnchorEl);

  const [otherAnchorEl, setOtherAnchorEl] = React.useState<null | HTMLElement>(null);
  const [tempOtherFilters, setTempOtherFilters] = React.useState<string[]>([]);

  const handleOtherClick = (event: React.MouseEvent<HTMLElement>) => {
    setOtherAnchorEl(event.currentTarget);
    setTempOtherFilters([...filters.other]);
  };

  const handleOtherClose = () => {
    setOtherAnchorEl(null);
  };

  const handleOtherChange = (value: string) => {
    const currentIndex = tempOtherFilters.indexOf(value);
    const newChecked = [...tempOtherFilters];

    if (currentIndex === -1) {
      newChecked.push(value);
    } else {
      newChecked.splice(currentIndex, 1);
    }

    setTempOtherFilters(newChecked);
  };

  const handleOtherApply = () => {
    const newFilters = {
      ...filters,
      other: tempOtherFilters,
    };
    setLocalFilters(newFilters);
    onFilterChange(newFilters);
    handleOtherClose();
  };

  const otherOpen = Boolean(otherAnchorEl);

  const handleOutcallChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const newFilters = {
      ...filters,
      outcall: event.target.checked,
    };
    setLocalFilters(newFilters);
    onFilterChange(newFilters);
  };

  const [priceAnchorEl, setPriceAnchorEl] = React.useState<null | HTMLElement>(null);
  const [tempPriceFilters, setTempPriceFilters] = React.useState(filters.price);

  const handlePriceClick = (event: React.MouseEvent<HTMLElement>) => {
    setPriceAnchorEl(event.currentTarget);
    setTempPriceFilters({...filters.price});
  };

  const handlePriceClose = () => {
    setPriceAnchorEl(null);
  };

  const handlePriceFromChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value === '' ? null : Number(event.target.value);
    setTempPriceFilters({
      ...tempPriceFilters,
      from: value,
    });
  };

  const handlePriceToChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value === '' ? null : Number(event.target.value);
    setTempPriceFilters({
      ...tempPriceFilters,
      to: value,
    });
  };

  const handleExpressChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setTempPriceFilters({
      ...tempPriceFilters,
      hasExpress: event.target.checked,
    });
  };

  const handlePriceApply = () => {
    const newFilters = {
      ...filters,
      price: tempPriceFilters,
    };
    setLocalFilters(newFilters);
    onFilterChange(newFilters);
    handlePriceClose();
  };

  const priceOpen = Boolean(priceAnchorEl);

  // Создаем переменную для отображения информации о цене
  const priceLabel = filters.price.from || filters.price.to ? 
    `${filters.price.from || ''}${filters.price.from && filters.price.to ? '-' : ''}${filters.price.to || ''}₽` : 
    '';

  const renderFilterButton = (label: string, onClick: (event: React.MouseEvent<HTMLElement>) => void) => (
    <ActionButton
      onClick={onClick}
      endIcon={<ArrowDownIcon />}
      variant="outlined"
      className="filter-button"
      sx={{
        justifyContent: 'space-between',
        textAlign: 'left',
        fontSize: isXSmall ? '0.75rem' : isMobile ? '0.875rem' : 'inherit',
      }}
    >
      {label}
    </ActionButton>
  );

  const renderFilterPopover = (
    anchorEl: HTMLElement | null,
    onClose: () => void,
    children: React.ReactNode,
    title: string,
    onApply: () => void
  ) => (
    <FilterPopover
      anchorEl={anchorEl}
      open={Boolean(anchorEl)}
      onClose={onClose}
      anchorOrigin={{
        vertical: 'bottom',
        horizontal: 'left',
      }}
      transformOrigin={{
        vertical: 'top',
        horizontal: 'left',
      }}
    >
      <Typography variant="subtitle1" gutterBottom sx={{ fontWeight: 'bold' }}>
        {title}
      </Typography>
      {children}
      <ApplyButton onClick={() => {
        onApply();
        onClose();
      }}>
        Применить
      </ApplyButton>
    </FilterPopover>
  );

  return (
    <FilterContainer>
      {renderFilterButton('Пол', handleGenderClick)}
      {renderFilterButton('Внешность', handleAppearanceClick)}
      {districts.length > 0 && renderFilterButton('Район', handleDistrictClick)}
      {renderFilterButton('Услуги', handleServicesClick)}
      {renderFilterButton('Проверка', handleVerificationClick)}
      {renderFilterButton('Остальное', handleOtherClick)}
      {renderFilterButton(`Цена ${priceLabel}`, handlePriceClick)}
      <ActionButton
        onClick={() => handleReset()}
        variant="outlined"
        color="error"
        sx={{ 
          gridColumn: isMobile ? 'span 2' : 'auto',
          fontSize: isXSmall ? '0.75rem' : isMobile ? '0.875rem' : 'inherit',
        }}
      >
        Сбросить
      </ActionButton>

      {renderFilterPopover(
        genderAnchorEl,
        handleGenderClose,
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
          {['Женщины', 'Мужчины', 'Транс'].map((value) => (
            <FormControlLabel
              key={value}
              control={
                <Checkbox
                  checked={tempGenderFilters.includes(value)}
                  onChange={() => handleGenderChange(value)}
                  size={isMobile ? 'small' : 'medium'}
                />
              }
              label={value}
              sx={{
                [theme.breakpoints.down('sm')]: {
                  margin: 0,
                  '& .MuiFormControlLabel-label': {
                    fontSize: '0.875rem',
                  },
                },
              }}
            />
          ))}
        </Box>,
        'Выберите пол',
        handleGenderApply
      )}

      {renderFilterPopover(
        appearanceAnchorEl,
        handleAppearanceClose,
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <RangeContainer>
            <Typography variant="subtitle2" gutterBottom>Возраст</Typography>
            <Slider
              value={tempAppearanceFilters.age}
              onChange={handleRangeChange('age')}
              valueLabelDisplay="auto"
              min={18}
              max={70}
              marks
              size={isMobile ? 'small' : 'medium'}
            />
          </RangeContainer>
          <RangeContainer>
            <Typography variant="subtitle2" gutterBottom>Рост</Typography>
            <Slider
              value={tempAppearanceFilters.height}
              onChange={handleRangeChange('height')}
              valueLabelDisplay="auto"
              min={140}
              max={195}
              marks
              size={isMobile ? 'small' : 'medium'}
            />
          </RangeContainer>
          <RangeContainer>
            <Typography variant="subtitle2" gutterBottom>Вес</Typography>
            <Slider
              value={tempAppearanceFilters.weight}
              onChange={handleRangeChange('weight')}
              valueLabelDisplay="auto"
              min={40}
              max={110}
              marks
              size={isMobile ? 'small' : 'medium'}
            />
          </RangeContainer>
        </Box>,
        'Внешность',
        handleAppearanceApply
      )}

      {renderFilterPopover(
        districtAnchorEl,
        handleDistrictClose,
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
          {districts.map((district) => (
            <FormControlLabel
              key={district}
              control={
                <Checkbox
                  checked={tempDistrictFilters.includes(district)}
                  onChange={() => handleDistrictChange(district)}
                  size={isMobile ? 'small' : 'medium'}
                />
              }
              label={district}
              sx={{
                [theme.breakpoints.down('sm')]: {
                  margin: 0,
                  '& .MuiFormControlLabel-label': {
                    fontSize: '0.875rem',
                  },
                },
              }}
            />
          ))}
        </Box>,
        'Выберите район',
        handleDistrictApply
      )}

      {renderFilterPopover(
        priceAnchorEl,
        handlePriceClose,
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Typography>От</Typography>
            <StyledTextField
              type="number"
              value={tempPriceFilters.from || ''}
              onChange={handlePriceFromChange}
              placeholder="0"
            />
            <Typography>До</Typography>
            <StyledTextField
              type="number"
              value={tempPriceFilters.to || ''}
              onChange={handlePriceToChange}
              placeholder="∞"
            />
          </Box>
          <FormControlLabel
            control={
              <Checkbox
                checked={tempPriceFilters.hasExpress}
                onChange={handleExpressChange}
                size={isMobile ? 'small' : 'medium'}
              />
            }
            label="Экспресс"
          />
        </Box>,
        'Цена за час',
        handlePriceApply
      )}

      {renderFilterPopover(
        servicesAnchorEl,
        handleServicesClose,
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
          {SERVICE_OPTIONS.map((service: Service) => (
            <FormControlLabel
              key={service}
              control={
                <Checkbox
                  checked={tempServicesFilters.includes(service)}
                  onChange={() => handleServicesChange(service)}
                  size={isMobile ? 'small' : 'medium'}
                />
              }
              label={serviceTranslations[service]}
              sx={{
                [theme.breakpoints.down('sm')]: {
                  margin: 0,
                  '& .MuiFormControlLabel-label': {
                    fontSize: '0.875rem',
                  },
                },
              }}
            />
          ))}
        </Box>,
        'Выберите услуги',
        handleServicesApply
      )}

      {renderFilterPopover(
        verificationAnchorEl,
        handleVerificationClose,
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
          {['Верифицирован', 'VIP', 'Новенькая'].map((value) => (
            <FormControlLabel
              key={value}
              control={
                <Checkbox
                  checked={tempVerificationFilters.includes(value)}
                  onChange={() => handleVerificationChange(value)}
                  size={isMobile ? 'small' : 'medium'}
                />
              }
              label={value}
              sx={{
                [theme.breakpoints.down('sm')]: {
                  margin: 0,
                  '& .MuiFormControlLabel-label': {
                    fontSize: '0.875rem',
                  },
                },
              }}
            />
          ))}
        </Box>,
        'Верификация',
        handleVerificationApply
      )}

      {renderFilterPopover(
        otherAnchorEl,
        handleOtherClose,
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
          <FormControlLabel
            control={
              <Checkbox
                checked={tempOtherFilters.includes('outcall')}
                onChange={() => handleOtherChange('outcall')}
                size={isMobile ? 'small' : 'medium'}
              />
            }
            label="Выезд"
          />
          <FormControlLabel
            control={
              <Checkbox
                checked={tempOtherFilters.includes('apartment')}
                onChange={() => handleOtherChange('apartment')}
                size={isMobile ? 'small' : 'medium'}
              />
            }
            label="Апартаменты"
          />
        </Box>,
        'Дополнительно',
        handleOtherApply
      )}
    </FilterContainer>
  );
};

export default FilterBar;
