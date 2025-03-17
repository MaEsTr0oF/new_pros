FROM node:18-slim

WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости системы
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем зависимости Node.js
RUN npm install

# Копируем исходный код
COPY . .

# Генерируем Prisma Client
RUN npx prisma generate

# Собираем приложение
RUN npm run build

# Открываем порт, который использует приложение
EXPOSE 5001

# Команда для запуска приложения
CMD ["npm", "start"]
