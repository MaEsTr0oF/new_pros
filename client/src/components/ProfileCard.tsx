import React from 'react';
import {
  Card,
  Typography,
  Box,
  Chip,
  styled,
  Badge,
  CardActionArea,
  useMediaQuery,
  useTheme,
} from '@mui/material';
import {
  DirectionsCar as CarIcon,
  Home as HomeIcon,
  VerifiedUser as VerifiedIcon,
} from '@mui/icons-material';
import { Profile } from '../types';
import { Link } from 'react-router-dom';

const StyledCard = styled(Card)(({ theme }) => ({
  position: 'relative',
  width: '100%',
  height: '100%',
  borderRadius: theme.spacing(1),
  overflow: 'hidden',
  transition: 'transform 0.2s ease-in-out',
  '&:hover': {
    transform: 'translateY(-4px)',
  },
}));

const LocationIcons = styled(Box)(({ theme }) => ({
  position: 'absolute',
  top: theme.spacing(1),
  right: theme.spacing(1),
  display: 'flex',
  gap: theme.spacing(1),
  zIndex: 1,
}));

const IconWrapper = styled(Box)(({ theme }) => ({
  backgroundColor: 'rgba(255, 255, 255, 0.9)',
  borderRadius: '50%',
  padding: theme.spacing(0.5),
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
}));

const VerificationBadge = styled(Chip)<{ verified?: boolean }>(({ theme, verified }) => ({
  position: 'absolute',
  left: theme.spacing(1),
  top: theme.spacing(1),
  backgroundColor: verified ? theme.palette.success.main : 'rgba(0, 0, 0, 0.5)',
  color: theme.palette.common.white,
  zIndex: 1,
  '& .MuiSvgIcon-root': {
    color: verified ? theme.palette.common.white : theme.palette.warning.main,
  },
  '&:hover': {
    backgroundColor: verified ? theme.palette.success.dark : 'rgba(0, 0, 0, 0.7)',
  }
}));

const PhotoCount = styled(Badge)(({ theme }) => ({
  position: 'absolute',
  top: theme.spacing(1),
  left: theme.spacing(1),
  zIndex: 1,
  '& .MuiBadge-badge': {
    backgroundColor: theme.palette.primary.main,
    color: theme.palette.common.white,
  },
}));

const ProfileImage = styled('img')({
  width: '100%',
  height: '400px',
  objectFit: 'cover',
  display: 'block',
});

const MobileProfileImage = styled('img')({
  width: '100%',
  height: '280px',
  objectFit: 'cover',
  display: 'block',
});

const InfoOverlay = styled(Box)(({ theme }) => ({
  position: 'absolute',
  bottom: 0,
  left: 0,
  right: 0,
  background: 'linear-gradient(to top, rgba(0, 0, 0, 0.8), transparent)',
  color: 'white',
  padding: theme.spacing(2),
}));

const MobileInfoOverlay = styled(Box)(({ theme }) => ({
  position: 'absolute',
  bottom: 0,
  left: 0,
  right: 0,
  background: 'linear-gradient(to top, rgba(0, 0, 0, 0.8), transparent)',
  color: 'white',
  padding: theme.spacing(1.5),
}));

const PriceChip = styled(Chip)(({ theme }) => ({
  backgroundColor: theme.palette.primary.main,
  color: 'white',
  fontWeight: 'bold',
  fontSize: '1.1rem',
}));

interface ProfileCardProps {
  profile: Profile;
}

const ProfileCard: React.FC<ProfileCardProps> = ({ profile }) => {
  const defaultImage = '/images/default-profile.jpg';
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  // Функция для генерации оптимизированного SEO-описания
  const getPhotoAlt = (): string => {
    const baseDesc = `${profile.name} - ${profile.age} лет`;
    const locationDesc = profile.city?.name ? `проститутка ${profile.city.name}` : 'проститутка';
    const physicalDesc = `${profile.height}см/${profile.weight}кг, грудь ${profile.breastSize}`;
    const priceDesc = `${profile.price1Hour}₽/час`;
    
    return `${baseDesc}, ${locationDesc}, ${physicalDesc}, ${priceDesc}`;
  };

  return (
    <StyledCard>
      <CardActionArea component={Link} to={`/profile/${profile.id}`}>
        <Box sx={{ position: 'relative' }}>
          <LocationIcons>
            {profile.inCall && (
              <IconWrapper>
                <HomeIcon color="primary" fontSize={isMobile ? "small" : "medium"} />
              </IconWrapper>
            )}
            {profile.outCall && (
              <IconWrapper>
                <CarIcon color="primary" fontSize={isMobile ? "small" : "medium"} />
              </IconWrapper>
            )}
          </LocationIcons>

          <VerificationBadge
            icon={<VerifiedIcon fontSize={isMobile ? "small" : "medium"} />}
            label={profile.isVerified ? "Проверено" : "Не проверено"}
            size="small"
            verified={profile.isVerified}
          />

          {profile.photos.length > 1 && (
            <PhotoCount
              badgeContent={profile.photos.length}
              color="primary"
              sx={{ position: 'absolute', top: theme.spacing(1), left: theme.spacing(10) }}
            />
          )}

          {isMobile ? (
            <MobileProfileImage
              src={profile.photos[0] || defaultImage}
              alt={getPhotoAlt()}
              onError={(e: React.SyntheticEvent<HTMLImageElement>) => {
                e.currentTarget.src = defaultImage;
              }}
            />
          ) : (
            <ProfileImage
              src={profile.photos[0] || defaultImage}
              alt={getPhotoAlt()}
              onError={(e: React.SyntheticEvent<HTMLImageElement>) => {
                e.currentTarget.src = defaultImage;
              }}
            />
          )}

          {isMobile ? (
            <MobileInfoOverlay>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 0.5 }}>
                <Typography variant="body1" component="h2" sx={{ color: 'white', fontWeight: 'bold' }}>
                  {profile.name}, {profile.age}
                </Typography>
                <PriceChip 
                  label={`${profile.price1Hour}₽`} 
                  size="small"
                  sx={{ fontSize: '0.9rem' }}
                />
              </Box>

              <Box sx={{ display: 'flex', gap: 0.5, mb: 0.5, flexWrap: 'wrap' }}>
                {profile.district && (
                  <Chip 
                    label={profile.district}
                    size="small"
                    sx={{ 
                      backgroundColor: 'rgba(255, 255, 255, 0.2)', 
                      color: 'white',
                      height: '20px',
                      fontSize: '0.7rem' 
                    }}
                  />
                )}
                {profile.city?.name && (
                  <Chip 
                    label={profile.city.name}
                    size="small"
                    sx={{ 
                      backgroundColor: 'rgba(255, 255, 255, 0.2)', 
                      color: 'white',
                      height: '20px',
                      fontSize: '0.7rem'
                    }}
                  />
                )}
              </Box>

              <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                <Typography variant="caption" sx={{ color: 'rgba(255, 255, 255, 0.9)' }}>
                  {profile.height} см
                </Typography>
                <Typography variant="caption" sx={{ color: 'rgba(255, 255, 255, 0.9)' }}>
                  {profile.weight} кг
                </Typography>
                <Typography variant="caption" sx={{ color: 'rgba(255, 255, 255, 0.9)' }}>
                  Грудь: {profile.breastSize}
                </Typography>
              </Box>

              {profile.isWaitingCall && (
                <Box sx={{ mt: 0.5 }}>
                  <Chip
                    label="Жду звонка"
                    color="success"
                    size="small"
                    sx={{ 
                      backgroundColor: '#4caf50', 
                      color: 'white',
                      height: '20px',
                      fontSize: '0.7rem'
                    }}
                  />
                </Box>
              )}
            </MobileInfoOverlay>
          ) : (
            <InfoOverlay>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                <Typography variant="h5" component="h2" sx={{ color: 'white', fontWeight: 'bold' }}>
                  {profile.name}, {profile.age}
                </Typography>
                <PriceChip label={`${profile.price1Hour}₽`} />
              </Box>

              <Box sx={{ display: 'flex', gap: 1, mb: 1, flexWrap: 'wrap' }}>
                {profile.district && (
                  <Chip 
                    label={profile.district}
                    size="small"
                    sx={{ backgroundColor: 'rgba(255, 255, 255, 0.2)', color: 'white' }}
                  />
                )}
                {profile.city?.name && (
                  <Chip 
                    label={profile.city.name}
                    size="small"
                    sx={{ backgroundColor: 'rgba(255, 255, 255, 0.2)', color: 'white' }}
                  />
                )}
              </Box>

              <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.9)' }}>
                  {profile.height} см
                </Typography>
                <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.9)' }}>
                  {profile.weight} кг
                </Typography>
                <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.9)' }}>
                  Грудь: {profile.breastSize}
                </Typography>
              </Box>

              {profile.isWaitingCall && (
                <Box sx={{ mt: 1 }}>
                  <Chip
                    label="Жду звонка"
                    color="success"
                    size="small"
                    sx={{ backgroundColor: '#4caf50', color: 'white' }}
                  />
                </Box>
              )}
            </InfoOverlay>
          )}
        </Box>
      </CardActionArea>
    </StyledCard>
  );
};

export default ProfileCard; 