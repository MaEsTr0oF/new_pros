#!/bin/bash
cat > /root/escort-project/server/src/controllers/cityController.ts << 'CITY_CONTROLLER'
import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getCities = async (req: Request, res: Response) => {
  try {
    const cities = await prisma.city.findMany({
      orderBy: {
        name: 'asc'  // Сортировка по имени в порядке возрастания
      }
    });
    res.json(cities);
  } catch (error) {
    console.error('Ошибка при получении городов:', error);
    res.status(500).json({ error: 'Не удалось получить города' });
  }
};

export const getCitiesPaginated = async (req: Request, res: Response) => {
  try {
    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 50;
    const skip = (page - 1) * limit;
    
    const [cities, total] = await prisma.$transaction([
      prisma.city.findMany({
        orderBy: { name: 'asc' },
        skip,
        take: limit
      }),
      prisma.city.count()
    ]);
    
    res.json({
      cities,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Ошибка при получении городов:', error);
    res.status(500).json({ error: 'Не удалось получить города' });
  }
};

export const createCity = async (req: Request, res: Response) => {
  try {
    const city = await prisma.city.create({
      data: req.body,
    });
    res.status(201).json(city);
  } catch (error) {
    console.error('Ошибка при создании города:', error);
    res.status(500).json({ error: 'Не удалось создать город' });
  }
};

export const updateCity = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const city = await prisma.city.update({
      where: { id: Number(id) },
      data: req.body,
    });
    res.json(city);
  } catch (error) {
    console.error('Ошибка при обновлении города:', error);
    res.status(500).json({ error: 'Не удалось обновить город' });
  }
};

export const deleteCity = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.city.delete({
      where: { id: Number(id) },
    });
    res.status(204).send();
  } catch (error) {
    console.error('Ошибка при удалении города:', error);
    res.status(500).json({ error: 'Не удалось удалить город' });
  }
};
CITY_CONTROLLER
echo "Файл cityController.ts обновлен"
