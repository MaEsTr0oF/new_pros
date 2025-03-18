#!/bin/bash
# Получаем текущее содержимое файла
CONTENT=$(cat /root/escort-project/server/src/controllers/profileController.ts)

# Проверяем, есть ли уже функции moveProfileUp и moveProfileDown
if grep -q "moveProfileUp" /root/escort-project/server/src/controllers/profileController.ts; then
  echo "Функция moveProfileUp уже существует"
else
  # Добавляем функции в конец файла
  cat >> /root/escort-project/server/src/controllers/profileController.ts << 'PROFILE_CONTROLLER_ADD'

export const moveProfileUp = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Находим текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId }
    });
    
    if (!currentProfile) {
      return res.status(404).json({ error: 'Профиль не найден' });
    }
    
    // Находим профиль выше (с меньшим order)
    const prevProfile = await prisma.profile.findFirst({
      where: {
        cityId: currentProfile.cityId,
        order: {
          lt: currentProfile.order
        }
      },
      orderBy: {
        order: 'desc'
      }
    });
    
    if (!prevProfile) {
      return res.status(200).json({ 
        message: 'Профиль уже находится в верхней позиции',
        profile: currentProfile
      });
    }
    
    // Меняем местами с предыдущим профилем
    await prisma.$transaction([
      prisma.profile.update({
        where: { id: profileId },
        data: { order: prevProfile.order }
      }),
      prisma.profile.update({
        where: { id: prevProfile.id },
        data: { order: currentProfile.order }
      })
    ]);
    
    const updatedProfile = await prisma.profile.findUnique({
      where: { id: profileId },
      include: { city: true }
    });
    
    res.json(updatedProfile);
  } catch (error) {
    console.error('Ошибка при перемещении профиля вверх:', error);
    res.status(500).json({ error: 'Не удалось переместить профиль вверх' });
  }
};

export const moveProfileDown = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Находим текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId }
    });
    
    if (!currentProfile) {
      return res.status(404).json({ error: 'Профиль не найден' });
    }
    
    // Находим профиль ниже (с большим order)
    const nextProfile = await prisma.profile.findFirst({
      where: {
        cityId: currentProfile.cityId,
        order: {
          gt: currentProfile.order
        }
      },
      orderBy: {
        order: 'asc'
      }
    });
    
    if (!nextProfile) {
      return res.status(200).json({ 
        message: 'Профиль уже находится в нижней позиции',
        profile: currentProfile
      });
    }
    
    // Меняем местами со следующим профилем
    await prisma.$transaction([
      prisma.profile.update({
        where: { id: profileId },
        data: { order: nextProfile.order }
      }),
      prisma.profile.update({
        where: { id: nextProfile.id },
        data: { order: currentProfile.order }
      })
    ]);
    
    const updatedProfile = await prisma.profile.findUnique({
      where: { id: profileId },
      include: { city: true }
    });
    
    res.json(updatedProfile);
  } catch (error) {
    console.error('Ошибка при перемещении профиля вниз:', error);
    res.status(500).json({ error: 'Не удалось переместить профиль вниз' });
  }
};
PROFILE_CONTROLLER_ADD
  echo "Функции moveProfileUp и moveProfileDown добавлены"
fi
