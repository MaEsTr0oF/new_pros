-- AlterTable добавляем поле order с начальным значением, равным id
ALTER TABLE "Profile" ADD COLUMN "order" INTEGER;
UPDATE "Profile" SET "order" = id;
ALTER TABLE "Profile" ALTER COLUMN "order" SET NOT NULL;
ALTER TABLE "Profile" ALTER COLUMN "order" SET DEFAULT 0;

-- Сортировка профилей в каждом городе по дате создания
WITH ordered_profiles AS (
  SELECT id, cityId, ROW_NUMBER() OVER (PARTITION BY cityId ORDER BY createdAt DESC) as new_order
  FROM "Profile"
)
UPDATE "Profile" p
SET "order" = op.new_order
FROM ordered_profiles op
WHERE p.id = op.id;
