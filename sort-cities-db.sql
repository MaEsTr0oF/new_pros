-- Обновление порядка сортировки городов по алфавиту
UPDATE "City" 
SET "order" = subquery.row_number
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY name COLLATE "C") as row_number
  FROM "City"
) AS subquery
WHERE "City".id = subquery.id;
