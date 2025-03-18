#!/bin/bash
set -e

echo "🔍 Проверяем и исправляем проблему с Nginx"

# Проверяем статус контейнера
echo "📋 Проверка статуса контейнера клиента:"
docker ps -a | grep escort-client

# Проверяем логи контейнера
echo "📋 Последние логи контейнера клиента:"
docker logs escort-client --tail 50

# Проверяем наличие файлов в контейнере
echo "📋 Проверка файлов в директории Nginx:"
docker exec escort-client ls -la /usr/share/nginx/html

# Проверяем конфигурацию Nginx
echo "📋 Проверка конфигурации Nginx:"
docker exec escort-client cat /etc/nginx/conf.d/default.conf

# Исправляем проблему с Nginx
echo "🔧 Восстанавливаем конфигурацию Nginx"

# Создаем правильную конфигурацию Nginx
cat > /root/escort-project/nginx.conf << 'EOFNGINX'
server {
    listen 80;
    listen 443 ssl;
    server_name eskortvsegorodarfreal.site;

    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Включаем HSTS для принудительного использования HTTPS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    root /usr/share/nginx/html;
    index index.html;

    # Настройки для SEO
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Frame-Options SAMEORIGIN;
    add_header Referrer-Policy strict-origin-when-cross-origin;
    
    # Базовый gzip для сжатия статических файлов
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Редирект с HTTP на HTTPS
    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://escort-server:5001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        
        # Таймауты
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Настройка кэширования статических файлов
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    # Обработка ошибок
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOFNGINX

# Копируем конфигурацию в контейнер
docker cp /root/escort-project/nginx.conf escort-client:/etc/nginx/conf.d/default.conf

# Пересобираем React-приложение вручную
echo "🏗️ Пересобираем React-приложение вручную"

# Создаем временный контейнер для сборки React-приложения
cd /root/escort-project

# Создаем временный Dockerfile для сборки
cat > temp-build.Dockerfile << 'EOFDOCKER'
FROM node:18-alpine
WORKDIR /app
COPY client/package*.json ./
RUN npm install
COPY client/ ./
ENV REACT_APP_API_URL=https://eskortvsegorodarfreal.site/api
RUN npm run build
CMD ["echo", "Build completed"]
EOFDOCKER

# Собираем временный образ
docker build -t temp-react-builder -f temp-build.Dockerfile .

# Создаем контейнер из этого образа
docker create --name temp-builder temp-react-builder

# Копируем собранные файлы из временного контейнера
rm -rf /root/escort-project/client-build || true
mkdir -p /root/escort-project/client-build
docker cp temp-builder:/app/build/. /root/escort-project/client-build/

# Проверяем, что файлы скопированы
ls -la /root/escort-project/client-build/

# Копируем собранные файлы в контейнер nginx
docker cp /root/escort-project/client-build/. escort-client:/usr/share/nginx/html/

# Очищаем временные ресурсы
docker rm temp-builder
docker rmi temp-react-builder

# Перезапускаем Nginx
echo "🔄 Перезапускаем Nginx"
docker exec escort-client nginx -s reload

# Проверяем статус после исправлений
echo "📋 Проверяем статус после исправлений:"
docker exec escort-client ls -la /usr/share/nginx/html

echo "✅ Исправления Nginx завершены"
echo "🌐 Сайт должен быть доступен по адресу: https://eskortvsegorodarfreal.site"
