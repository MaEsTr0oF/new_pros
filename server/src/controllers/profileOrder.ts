import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Функция для перемещения профиля вверх (уменьшение порядкового номера)
export const moveProfileUp = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = parseInt(id);
    
    // Получаем текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId }
    });
    
    if (!currentProfile) {
      return res.status(404).json({ error: 'Профиль не найден' });
    }
    
    // Находим профиль, который находится выше (с меньшим order)
    const prevProfile = await prisma.profile.findFirst({
      where: {
        cityId: currentProfile.cityId,
        order: { lt: currentProfile.order }
      },
      orderBy: { order: 'desc' }
    });
    
    if (!prevProfile) {
      return res.status(400).json({ message: 'Профиль уже находится вверху списка' });
    }
    
    // Меняем местами порядковые номера
    await prisma.$transaction([
      prisma.profile.update({
        where: { id: currentProfile.id },
        data: { order: prevProfile.order }
      }),
      prisma.profile.update({
        where: { id: prevProfile.id },
        data: { order: currentProfile.order }
      })
    ]);
    
    res.json({ message: 'Профиль перемещен вверх' });
  } catch (error) {
    console.error('Ошибка при перемещении профиля вверх:', error);
    res.status(500).json({ error: 'Не удалось переместить профиль' });
  }
};

// Функция для перемещения профиля вниз (увеличение порядкового номера)
export const moveProfileDown = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = parseInt(id);
    
    // Получаем текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId }
    });
    
    if (!currentProfile) {
      return res.status(404).json({ error: 'Профиль не найден' });
    }
    
    // Находим профиль, который находится ниже (с большим order)
    const nextProfile = await prisma.profile.findFirst({
      where: {
        cityId: currentProfile.cityId,
        order: { gt: currentProfile.order }
      },
      orderBy: { order: 'asc' }
    });
    
    if (!nextProfile) {
      return res.status(400).json({ message: 'Профиль уже находится внизу списка' });
    }
    
    // Меняем местами порядковые номера
    await prisma.$transaction([
      prisma.profile.update({
        where: { id: currentProfile.id },
        data: { order: nextProfile.order }
      }),
      prisma.profile.update({
        where: { id: nextProfile.id },
        data: { order: currentProfile.order }
      })
    ]);
    
    res.json({ message: 'Профиль перемещен вниз' });
  } catch (error) {
    console.error('Ошибка при перемещении профиля вниз:', error);
    res.status(500).json({ error: 'Не удалось переместить профиль' });
  }
};
