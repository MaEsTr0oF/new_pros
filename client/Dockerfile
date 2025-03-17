FROM node:18-alpine as build

WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем исходный код
COPY . .

# Устанавливаем переменную окружения
ENV REACT_APP_API_URL=https://eskortvsegorodarfreal.site/api
# Собираем приложение
RUN npm run build

# Второй этап сборки - nginx для статического сервинга
FROM nginx:alpine

# Копируем собранное приложение из первого этапа
COPY --from=build /app/build /usr/share/nginx/html

# Копируем конфигурацию nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открываем порт
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"] 