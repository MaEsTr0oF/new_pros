// Найти функцию renderFilterButton и обернуть группу фильтров в контейнер с классом filter-buttons-container
// Добавить импорт стилей

// 1. Добавьте в начало файла FilterBar.tsx:
import '../styles/filter-styles.css';

// 2. Найдите функцию render и модифицируйте контейнер с фильтрами:
// Замените
<Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 2 }}>
  {renderFilterButton('Пол', handleGenderClick)}
  {renderFilterButton('Внешность', handleAppearanceClick)}
  {renderFilterButton('Район', handleDistrictClick)}
  {renderFilterButton('Услуги', handleServicesClick)}
  {renderFilterButton('Проверка', handleVerificationClick)}
  {renderFilterButton('Прочее', handleOtherClick)}
  {renderFilterButton('Цена', handlePriceClick)}
  {/* Другие фильтры */}
</Box>

// На:
<Box className="filter-buttons-container">
  {renderFilterButton('Пол', handleGenderClick)}
  {renderFilterButton('Внешность', handleAppearanceClick)}
  {renderFilterButton('Район', handleDistrictClick)}
  {renderFilterButton('Услуги', handleServicesClick)}
  {renderFilterButton('Проверка', handleVerificationClick)}
  {renderFilterButton('Прочее', handleOtherClick)}
  {renderFilterButton('Цена', handlePriceClick)}
  {/* Другие фильтры */}
</Box>

// 3. Модифицируйте функцию renderFilterButton:
const renderFilterButton = (label: string, onClick: (event: React.MouseEvent<HTMLElement>) => void) => (
  <Button
    className="filter-button"
    variant="outlined"
    onClick={onClick}
    endIcon={<IconComponent />}
    sx={{
      borderRadius: '20px',
      textTransform: 'none', 
      minWidth: { xs: '70px', sm: '80px' },
      fontSize: { xs: '0.8rem', sm: '0.9rem' }
    }}
  >
    {label}
  </Button>
);
