import React from 'react';
import { Helmet } from 'react-helmet';

interface SEOProps {
  title?: string;
  description?: string;
  keywords?: string;
  canonicalUrl?: string;
  ogImage?: string;
  cityName?: string;
  isHomePage?: boolean;
}

const SEO: React.FC<SEOProps> = ({
  title = 'Эскорт услуги в России | VIP анкеты девушек',
  description = 'Эскорт услуги в России. Анкеты VIP девушек с фото и отзывами. Высокий уровень сервиса и конфиденциальность.',
  keywords = 'эскорт услуги, vip эскорт, элитный эскорт, escort services, проститутки',
  canonicalUrl = 'https://eskortvsegorodarfreal.site',
  ogImage = 'https://eskortvsegorodarfreal.site/logo192.png',
  cityName,
  isHomePage = false
}) => {
  // Если указан город, модифицируем мета-теги
  const finalTitle = cityName 
    ? `Проститутки ${cityName} | Эскорт-услуги и VIP анкеты девушек` 
    : title;
    
  const finalDescription = cityName 
    ? `Элитные проститутки ${cityName}. Анкеты VIP девушек с реальными фото. Индивидуалки ${cityName} с проверенными отзывами. Высокий уровень сервиса и конфиденциальность.` 
    : description;
    
  const finalKeywords = cityName 
    ? `проститутки ${cityName}, эскорт ${cityName}, vip эскорт ${cityName}, индивидуалки ${cityName}, вип девушки ${cityName}, интим услуги ${cityName}, элитные проститутки ${cityName}` 
    : keywords;
    
  const citySlug = cityName ? cityName.toLowerCase().replace(/\s+/g, '-') : '';
  const finalCanonicalUrl = cityName 
    ? `https://eskortvsegorodarfreal.site/${citySlug}` 
    : canonicalUrl;
    
  // Генерация Schema.org разметки в формате JSON-LD
  const generateSchemaOrgJSONLD = () => {
    // Базовая схема для всех страниц
    const baseSchema = {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      'url': 'https://eskortvsegorodarfreal.site',
      'name': 'Эскорт услуги в России',
      'description': 'Эскорт услуги и VIP анкеты девушек в России'
    };
    
    // Дополнительная схема для страниц городов
    if (cityName) {
      const localBusinessSchema = {
        '@context': 'https://schema.org',
        '@type': 'LocalBusiness',
        'name': `Эскорт услуги в ${cityName}`,
        'description': finalDescription,
        'address': {
          '@type': 'PostalAddress',
          'addressLocality': cityName,
          'addressCountry': 'Россия'
        },
        'url': finalCanonicalUrl
      };
      
      return [
        baseSchema,
        localBusinessSchema
      ];
    }
    
    // Добавляем BreadcrumbList для SEO если это не главная страница
    if (!isHomePage) {
      const breadcrumbSchema = {
        '@context': 'https://schema.org',
        '@type': 'BreadcrumbList',
        'itemListElement': [
          {
            '@type': 'ListItem',
            'position': 1,
            'name': 'Главная',
            'item': 'https://eskortvsegorodarfreal.site'
          },
          {
            '@type': 'ListItem',
            'position': 2,
            'name': cityName || 'Страница',
            'item': finalCanonicalUrl
          }
        ]
      };
      
      return [baseSchema, breadcrumbSchema];
    }
    
    return [baseSchema];
  };

  return (
    <Helmet>
      <title>{finalTitle}</title>
      <meta name="description" content={finalDescription} />
      <meta name="keywords" content={finalKeywords} />
      <link rel="canonical" href={finalCanonicalUrl} />
      
      {/* Open Graph теги для социальных сетей и мессенджеров */}
      <meta property="og:title" content={finalTitle} />
      <meta property="og:description" content={finalDescription} />
      <meta property="og:type" content="website" />
      <meta property="og:url" content={finalCanonicalUrl} />
      <meta property="og:image" content={ogImage} />
      <meta property="og:locale" content="ru_RU" />
      
      {/* Twitter Card теги */}
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content={finalTitle} />
      <meta name="twitter:description" content={finalDescription} />
      <meta name="twitter:image" content={ogImage} />

      {/* Дополнительные мета-теги */}
      <meta name="robots" content="index, follow, max-image-preview:large" />
      <meta name="language" content="Russian" />
      <meta name="revisit-after" content="1 days" />
      <meta name="author" content="Escort Services" />
      <meta name="geo.region" content="RU" />
      {cityName && <meta name="geo.placename" content={cityName} />}
      
      {/* Schema.org JSON-LD разметка */}
      <script type="application/ld+json">
        {JSON.stringify(generateSchemaOrgJSONLD())}
      </script>
    </Helmet>
  );
};

export default SEO; 