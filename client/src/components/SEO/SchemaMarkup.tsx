import React from 'react';
import { Helmet } from 'react-helmet';

interface Profile {
  id: string | number;
  name?: string;
  age?: number;
  description?: string;
  photos?: string[];
  gender?: string;
  height?: number;
  weight?: number;
  city?: { name: string };
}

interface SchemaMarkupProps {
  profile: Profile;
}

const SchemaMarkup: React.FC<SchemaMarkupProps> = ({ profile }) => {
  const schemaData = {
    '@context': 'https://schema.org',
    '@type': 'Person',
    'name': profile.name || '',
    'description': `${profile.name || ''}, ${profile.age || ''} лет. ${profile.description || 'Элитная эскорт-услуга'}`,
    'image': profile.photos && profile.photos.length > 0 ? profile.photos[0] : 'https://eskortvsegorodarfreal.site/logo192.png',
    'url': `https://eskortvsegorodarfreal.site/profile/${profile.id || ''}`,
    'gender': profile.gender === 'female' ? 'Female' : 'Male',
    'height': profile.height ? `${profile.height} см` : undefined,
    'weight': profile.weight ? `${profile.weight} кг` : undefined,
    'address': {
      '@type': 'PostalAddress',
      'addressLocality': profile.city?.name || 'Москва',
      'addressCountry': 'RU'
    }
  };

  return (
    <Helmet>
      <script type="application/ld+json">
        {JSON.stringify(schemaData)}
      </script>
    </Helmet>
  );
};

export default SchemaMarkup; 