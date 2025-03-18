import express, { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const router = express.Router();

// Получение районов по городу
router.get('/districts/:cityId', async (req: Request, res: Response) => {
  try {
    const cityId = parseInt(req.params.cityId);
    if (isNaN(cityId)) {
      return res.status(400).json({ error: 'Некорректный ID города' });
    }

    // Получаем уникальные районы из профилей данного города
    const districts = await prisma.profile.findMany({
      where: {
        cityId: cityId,
        district: {
          not: null
        }
      },
      select: {
        district: true
      },
      distinct: ['district']
    });

    const districtList = districts
      .map(item => item.district as string)
      .filter((district): district is string => district !== null && district !== "")
      .sort((a, b) => a.localeCompare(b, 'ru'));

    res.json(districtList);
  } catch (error) {
    console.error('Ошибка при получении районов:', error);
    res.status(500).json({ error: 'Не удалось получить районы' });
  }
});

// Получение доступных услуг
router.get('/services', async (_req: Request, res: Response) => {
  try {
    // Статический список услуг
    const services = [
      'classic', 'anal', 'lesbian', 'group_mmf', 'group_ffm', 'with_toys',
      'in_car', 'blowjob_with_condom', 'blowjob_without_condom', 'deep_blowjob',
      'car_blowjob', 'anilingus_to_client', 'fisting_to_client', 'kisses',
      'light_domination', 'mistress', 'flogging', 'trampling', 'face_sitting',
      'strapon', 'bondage', 'slave', 'role_play', 'foot_fetish', 'golden_rain_out',
      'golden_rain_in', 'copro_out', 'copro_in', 'enema', 'relaxing',
      'professional', 'body_massage', 'lingam_massage', 'four_hands',
      'urological', 'strip_pro', 'strip_amateur', 'belly_dance', 'twerk',
      'lesbian_show', 'sex_chat', 'phone_sex', 'video_sex', 'photo_video',
      'invite_girlfriend', 'invite_friend', 'escort', 'photoshoot', 'skirt'
    ];
    
    res.json(services);
  } catch (error) {
    console.error('Ошибка при получении услуг:', error);
    res.status(500).json({ error: 'Не удалось получить услуги' });
  }
});

export default router;
