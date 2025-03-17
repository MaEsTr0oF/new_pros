import React from 'react';
import SEO from './SEO';

interface CommonSEOProps {
  cityName?: string;
  isHomePage?: boolean;
}

/**
 * Компонент CommonSEO для использования одинаковых метаданных на всех страницах сайта
 * Это обеспечивает одинаковое отображение ссылок при пересылке в мессенджерах и соцсетях
 */
const CommonSEO: React.FC<CommonSEOProps> = ({ cityName, isHomePage = false }) => {
  return (
    <SEO 
      title="Эскорт услуги в России | VIP анкеты девушек"
      description="Эскорт услуги в России. Анкеты VIP девушек с фото и отзывами. Высокий уровень сервиса и конфиденциальность."
      keywords="эскорт, вип эскорт, элитный эскорт, проститутки, девушки"
      cityName={cityName}
      isHomePage={isHomePage}
    />
  );
};

export default CommonSEO; 