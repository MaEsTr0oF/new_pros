-- Проверяем наличие поля sortOrder в таблице City
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name='City' AND column_name='sortOrder'
  ) THEN
    -- Создаем временную колонку для хранения порядка сортировки
    ALTER TABLE "City" ADD COLUMN "sortOrder" SERIAL;
  END IF;
END$$;

-- Обновляем порядок сортировки в соответствии с алфавитным порядком
WITH sorted_cities AS (
  SELECT 
    id, 
    ROW_NUMBER() OVER (ORDER BY name ASC) AS row_num
  FROM "City"
)
UPDATE "City" 
SET "sortOrder" = sorted_cities.row_num
FROM sorted_cities
WHERE "City".id = sorted_cities.id;

-- Выводим результат для проверки
SELECT id, name, "sortOrder" FROM "City" ORDER BY "sortOrder";
