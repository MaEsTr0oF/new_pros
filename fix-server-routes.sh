#!/bin/bash

echo "🔧 Добавление маршрутов для изменения порядка профилей на сервере..."

# Проверяем наличие файла контроллера профилей
CONTROLLER_FILE="/root/escort-project/server/src/controllers/profileController.ts"

if [ -f "$CONTROLLER_FILE" ]; then
  # Добавляем функции moveProfileUp и moveProfileDown в конец файла контроллера, если их еще нет
  if ! grep -q "moveProfileUp" "$CONTROLLER_FILE"; then
    cat >> "$CONTROLLER_FILE" << 'ENDCONTROLLER'

export const moveProfileUp = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Получаем текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId },
      select: { order: true, cityId: true }
    });

    if (!currentProfile) {
      return res.status(404).json({ error: 'Профиль не найден' });
    }

    // Находим профиль выше по порядку в том же городе
    const prevProfile = await prisma.profile.findFirst({
      where: { 
        cityId: currentProfile.cityId,
        order: { lt: currentProfile.order }
      },
      orderBy: { order: 'desc' },
      select: { id: true, order: true }
    });

    if (!prevProfile) {
      return res.status(400).json({ message: 'Профиль уже на верхней позиции' });
    }

    // Обновляем порядок профилей
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

    res.json({ message: 'Порядок профилей успешно обновлен' });
  } catch (error) {
    console.error('Ошибка при перемещении профиля вверх:', error);
    res.status(500).json({ error: 'Не удалось переместить профиль вверх' });
  }
};

export const moveProfileDown = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const profileId = Number(id);
    
    // Получаем текущий профиль
    const currentProfile = await prisma.profile.findUnique({
      where: { id: profileId },
      select: { order: true, cityId: true }
    });

    if (!currentProfile) {
      return res.status(404).json({ error: 'Профиль не найден' });
    }

    // Находим профиль ниже по порядку в том же городе
    const nextProfile = await prisma.profile.findFirst({
      where: { 
        cityId: currentProfile.cityId,
        order: { gt: currentProfile.order }
      },
      orderBy: { order: 'asc' },
      select: { id: true, order: true }
    });

    if (!nextProfile) {
      return res.status(400).json({ message: 'Профиль уже на нижней позиции' });
    }

    // Обновляем порядок профилей
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

    res.json({ message: 'Порядок профилей успешно обновлен' });
  } catch (error) {
    console.error('Ошибка при перемещении профиля вниз:', error);
    res.status(500).json({ error: 'Не удалось переместить профиль вниз' });
  }
};
ENDCONTROLLER
  fi
fi

# Добавляем маршруты в индексный файл сервера
SERVER_INDEX="/root/escort-project/server/src/index.ts"

if [ -f "$SERVER_INDEX" ]; then
  # Добавляем маршруты для перемещения профилей, если их еще нет
  if ! grep -q "move-up" "$SERVER_INDEX"; then
    # Находим место где объявлены защищенные маршруты
    ROUTES_LINE=$(grep -n "app.use('/api/admin'" "$SERVER_INDEX" | cut -d':' -f1)
    
    if [ -n "$ROUTES_LINE" ]; then
      # Находим последний маршрут для профилей
      LAST_PROFILE_ROUTE=$(grep -n "app.patch('/api/admin/profiles/" "$SERVER_INDEX" | tail -1 | cut -d':' -f1)
      
      if [ -n "$LAST_PROFILE_ROUTE" ]; then
        # Вставляем новые маршруты после последнего маршрута для профилей
        sed -i "$LAST_PROFILE_ROUTE a\\app.post('/api/admin/profiles/:id/move-up', profileController.moveProfileUp);\napp.post('/api/admin/profiles/:id/move-down', profileController.moveProfileDown);" "$SERVER_INDEX"
        
        echo "✅ Маршруты для перемещения профилей добавлены в $SERVER_INDEX"
      else
        echo "❌ Не удалось найти место для вставки маршрутов"
      fi
    else
      echo "❌ Не удалось найти раздел защищенных маршрутов"
    fi
  else
    echo "✅ Маршруты для перемещения профилей уже существуют"
  fi
fi

echo "✅ Установка маршрутов завершена!"
