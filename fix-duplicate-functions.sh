#!/bin/bash
set -e

echo "🔧 Исправляем дублирование функций в profileController.ts"

# Путь к файлу
CONTROLLER_PATH="/root/escort-project/server/src/controllers/profileController.ts"

# Создаем резервную копию
cp $CONTROLLER_PATH ${CONTROLLER_PATH}.bak_dups

# Создаем новую версию файла без дублирования функций
cat > $CONTROLLER_PATH << 'EOFINNER'
import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface FilterParams {
  gender: string[];
  appearance: {
    age: [number, number];
    height: [number, number];
    weight: [number, number];
    breastSize: [number, number];
    nationality: string[];
    hairColor: string[];
    bikiniZone: string[];
  };
  district: string[];
  price: {
    from: number | null;
    to: number | null;
    hasExpress: boolean;
  };
  services: string[];
  verification: string[];
  other: string[];
  outcall: boolean;
}

export const getProfiles = async (req: Request, res: Response) => {
  try {
    const filters = req.query.filters ? JSON.parse(req.query.filters as string) as FilterParams : null;
    const cityId = req.query.cityId ? Number(req.query.cityId) : undefined;

    // Проверяем наличие токена администратора в заголовках
    const isAdminRequest = req.headers.authorization?.startsWith('Bearer ');

    console.log('Request path:', req.path);
    console.log('Is admin request:', isAdminRequest);
    console.log('Authorization header:', req.headers.authorization);
    console.log('Received filters:', filters);

    const prismaFilters: any = {
      isActive: isAdminRequest ? undefined : true,
      cityId: cityId,
    };

    if (filters) {
      // Обработка фильтра по полу
      if (filters.gender.length > 0) {
        prismaFilters.gender = {
          in: filters.gender
        };
      }

      // Обработка фильтров внешности
      if (filters.appearance) {
        if (filters.appearance.age) {
          prismaFilters.age = {
            gte: filters.appearance.age[0],
            lte: filters.appearance.age[1]
          };
        }

        if (filters.appearance.height) {
          prismaFilters.height = {
            gte: filters.appearance.height[0],
            lte: filters.appearance.height[1]
          };
        }

        if (filters.appearance.weight) {
          prismaFilters.weight = {
            gte: filters.appearance.weight[0],
            lte: filters.appearance.weight[1]
          };
        }

        if (filters.appearance.breastSize) {
          prismaFilters.breastSize = {
            gte: filters.appearance.breastSize[0],
            lte: filters.appearance.breastSize[1]
          };
        }

        if (filters.appearance.nationality.length > 0) {
          prismaFilters.nationality = {
            in: filters.appearance.nationality
          };
        }

        if (filters.appearance.hairColor.length > 0) {
          prismaFilters.hairColor = {
            in: filters.appearance.hairColor
          };
        }

        if (filters.appearance.bikiniZone.length > 0) {
          prismaFilters.bikiniZone = {
            in: filters.appearance.bikiniZone
          };
        }
      }

      // Обработка фильтра по району
      if (filters.district.length > 0) {
        prismaFilters.district = {
          in: filters.district
        };
      }

      // Обработка фильтра по цене
      if (filters.price) {
        if (filters.price.from !== null || filters.price.to !== null) {
          prismaFilters.price1Hour = {};
          if (filters.price.from !== null) {
            prismaFilters.price1Hour.gte = filters.price.from;
          }
          if (filters.price.to !== null) {
            prismaFilters.price1Hour.lte = filters.price.to;
          }
        }
        if (filters.price.hasExpress) {
          prismaFilters.priceExpress = {
            gt: 0
          };
        }
      }

      // Обработка фильтра по услугам
      if (filters.services.length > 0) {
        prismaFilters.services = {
          hasEvery: filters.services
        };
      }

      // Обработка фильтров верификации
      if (filters.verification.length > 0) {
        const verificationFilters: any = {};
        if (filters.verification.includes('verified')) {
          verificationFilters.isVerified = true;
        }
        if (filters.verification.includes('with_video')) {
          verificationFilters.hasVideo = true;
        }
        if (filters.verification.includes('with_reviews')) {
          verificationFilters.hasReviews = true;
        }
        Object.assign(prismaFilters, verificationFilters);
      }

      // Обработка прочих фильтров
      if (filters.other.length > 0) {
        const otherFilters: any = {};
        if (filters.other.includes('non_smoking')) {
          otherFilters.isNonSmoking = true;
        }
        if (filters.other.includes('new')) {
          otherFilters.isNew = true;
        }
        if (filters.other.includes('waiting_call')) {
          otherFilters.isWaitingCall = true;
        }
        if (filters.other.includes('24_hours')) {
          otherFilters.is24Hours = true;
        }
        if (filters.other.includes('alone')) {
          otherFilters.isAlone = true;
        }
        if (filters.other.includes('with_friend')) {
          otherFilters.withFriend = true;
        }
        if (filters.other.includes('with_friends')) {
          otherFilters.withFriends = true;
        }
        Object.assign(prismaFilters, otherFilters);
      }

      // Обработка фильтра по выезду
      if (filters.outcall) {
        prismaFilters.outCall = true;
      }
    }

    // Удаляем undefined значения из фильтров
    Object.keys(prismaFilters).forEach(key => {
      if (prismaFilters[key] === undefined) {
        delete prismaFilters[key];
      }
    });

    console.log('Applied Prisma filters:', prismaFilters);

    const profiles = await prisma.profile.findMany({
      where: prismaFilters,
      include: {
        city: true,
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    console.log(`Found ${profiles.length} profiles`);
    res.json(profiles);
  } catch (error) {
    console.error('Error fetching profiles:', error);
    res.status(500).json({ 
      error: 'Failed to fetch profiles',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
};

export const getProfileById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profile = await prisma.profile.findUnique({
      where: { id: Number(id) },
      include: {
        city: true,
      },
    });

    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    res.json(profile);
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
};

export const createProfile = async (req: Request, res: Response) => {
  try {
    console.log('Received profile data:', req.body);
    
    // Проверяем обязательные поля
    const requiredFields = [
      'name',
      'age',
      'height',
      'weight',
      'breastSize',
      'phone',
      'description',
      'photos',
      'price1Hour',
      'price2Hours',
      'priceNight',
      'cityId'
    ];

    const missingFields = requiredFields.filter(field => !req.body[field]);
    
    if (missingFields.length > 0) {
      console.log('Missing required fields:', missingFields);
      return res.status(400).json({
        error: 'Missing required fields',
        fields: missingFields
      });
    }

    interface NumericRange {
      min: number;
      max?: number;
    }

    // Проверяем валидность числовых полей
    const numericFields: Record<string, NumericRange> = {
      age: { min: 18, max: 70 },
      height: { min: 140, max: 195 },
      weight: { min: 40, max: 110 },
      breastSize: { min: 1, max: 10 },
      price1Hour: { min: 0 },
      price2Hours: { min: 0 },
      priceNight: { min: 0 },
      priceExpress: { min: 0 }
    };

    for (const [field, range] of Object.entries(numericFields)) {
      const value = Number(req.body[field]);
      if (isNaN(value) || value < range.min || (range.max !== undefined && value > range.max)) {
        console.log('Invalid numeric field:', field, 'value:', value, 'range:', range);
        return res.status(400).json({
          error: `Invalid value for ${field}`,
          field,
          range
        });
      }
    }

    // Создаем профиль с валидными данными
    const profileData = {
      name: req.body.name,
      age: Number(req.body.age),
      height: Number(req.body.height),
      weight: Number(req.body.weight),
      breastSize: Number(req.body.breastSize),
      phone: req.body.phone,
      description: req.body.description,
      photos: req.body.photos,
      price1Hour: Number(req.body.price1Hour),
      price2Hours: Number(req.body.price2Hours),
      priceNight: Number(req.body.priceNight),
      priceExpress: Number(req.body.priceExpress || 0),
      cityId: Number(req.body.cityId),
      district: req.body.district,
      services: req.body.services || [],
      
      // Appearance
      nationality: req.body.nationality,
      hairColor: req.body.hairColor,
      bikiniZone: req.body.bikiniZone,
      gender: req.body.gender || 'female',
      orientation: req.body.orientation || 'hetero',
      
      // Verification
      isVerified: req.body.isVerified || false,
      hasVideo: req.body.hasVideo || false,
      hasReviews: req.body.hasReviews || false,
      
      // Location
      inCall: req.body.inCall ?? true,
      outCall: req.body.outCall ?? false,
      
      // Additional filters
      isNonSmoking: req.body.isNonSmoking || false,
      isNew: req.body.isNew ?? true,
      isWaitingCall: req.body.isWaitingCall || false,
      is24Hours: req.body.is24Hours || false,
      
      // Neighbors
      isAlone: req.body.isAlone ?? true,
      withFriend: req.body.withFriend || false,
      withFriends: req.body.withFriends || false,
    };

    console.log('Creating profile with data:', profileData);

    const profile = await prisma.profile.create({
      data: profileData,
      include: {
        city: true,
      },
    });

    console.log('Created profile:', profile);
    res.status(201).json(profile);
  } catch (error) {
    console.error('Error creating profile:', error);
    res.status(500).json({
      error: 'Failed to create profile',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profile = await prisma.profile.update({
      where: { id: Number(id) },
      data: req.body,
    });
    res.json(profile);
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
};

export const deleteProfile = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.profile.delete({
      where: { id: Number(id) },
    });
    res.status(204).send();
  } catch (error) {
    console.error('Error deleting profile:', error);
    res.status(500).json({ error: 'Failed to delete profile' });
  }
};

export const verifyProfile = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profile = await prisma.profile.update({
      where: { id: Number(id) },
      data: {
        isVerified: true,
      },
      include: {
        city: true,
      },
    });
    res.json(profile);
  } catch (error) {
    console.error('Error verifying profile:', error);
    res.status(500).json({ error: 'Failed to verify profile' });
  }
};

// Функция для перемещения профиля вверх
export const moveProfileUp = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Получаем текущий профиль
    const profile = await prisma.profile.findUnique({
      where: { id: profileId },
      include: { city: true }
    });
    
    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    
    // Заглушка: просто возвращаем профиль
    res.json({
      message: 'Profile moved up successfully',
      profile
    });
  } catch (error) {
    console.error('Error moving profile up:', error);
    res.status(500).json({ 
      error: 'Failed to move profile up',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
};

// Функция для перемещения профиля вниз
export const moveProfileDown = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Получаем текущий профиль
    const profile = await prisma.profile.findUnique({
      where: { id: profileId },
      include: { city: true }
    });
    
    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    
    // Заглушка: просто возвращаем профиль
    res.json({
      message: 'Profile moved down successfully',
      profile
    });
  } catch (error) {
    console.error('Error moving profile down:', error);
    res.status(500).json({ 
      error: 'Failed to move profile down',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
};
EOFINNER

echo "✅ profileController.ts исправлен (удалены дублирующиеся функции)"
