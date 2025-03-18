-- Проверяем, существует ли колонка order в таблице Profile
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'Profile'
    AND column_name = 'order'
  ) THEN
    -- Добавляем колонку order в таблицу Profile
    ALTER TABLE "Profile" ADD COLUMN "order" INTEGER NOT NULL DEFAULT 0;
    
    -- Инициализируем порядок на основе id
    UPDATE "Profile" SET "order" = id;
  END IF;
END $$;
