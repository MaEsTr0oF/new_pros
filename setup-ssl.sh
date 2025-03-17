#!/bin/bash

echo "🔒 Настройка SSL-сертификата для домена eskortvsegorodarfreal.site"

# Проверка наличия домена и его связи с IP сервера
echo "🌐 Проверка DNS-настройки..."
server_ip=$(curl -s ifconfig.me)
domain="eskortvsegorodarfreal.site"
domain_ip=$(dig +short $domain | head -n1)

if [ -z "$domain_ip" ]; then
    echo "❌ Ошибка: Домен $domain не настроен в DNS"
    exit 1
fi

if [ "$server_ip" != "$domain_ip" ]; then
    echo "❌ Ошибка: IP сервера ($server_ip) не соответствует IP домена ($domain_ip)"
    echo "⚠️ Обновите DNS-запись типа A для домена $domain на IP $server_ip"
    exit 1
fi

echo "✅ DNS настройки корректны: $domain -> $domain_ip"

# Установка Certbot
echo "📦 Установка Certbot..."
apt-get update
apt-get install -y certbot

# Создание директории для SSL сертификатов
mkdir -p ./ssl
mkdir -p /etc/nginx/ssl

# Остановка контейнера nginx для получения сертификата
echo "🛑 Останавливаем контейнеры..."
docker-compose down client

# Получение сертификата SSL с помощью Certbot
echo "🔑 Получение SSL-сертификата..."
certbot certonly --standalone --non-interactive --agree-tos --email admin@example.com -d $domain

# Копирование сертификатов в директорию nginx
echo "📋 Копирование сертификатов..."
cp /etc/letsencrypt/live/$domain/fullchain.pem ./ssl/fullchain.pem
cp /etc/letsencrypt/live/$domain/privkey.pem ./ssl/privkey.pem

# Обновление прав доступа для сертификатов
chmod 755 ./ssl
chmod 644 ./ssl/fullchain.pem ./ssl/privkey.pem

# Копирование сертификатов в директорию nginx для монтирования
cp ./ssl/* /etc/nginx/ssl/

# Перезапуск контейнеров
echo "🚀 Перезапуск контейнеров..."
docker-compose up -d

echo "✅ SSL-сертификат успешно установлен для домена $domain"
echo "🔄 Настройка автоматического обновления сертификата..."

# Добавление задачи cron для автоматического обновления сертификата
(crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet && cp /etc/letsencrypt/live/$domain/fullchain.pem /etc/nginx/ssl/ && cp /etc/letsencrypt/live/$domain/privkey.pem /etc/nginx/ssl/ && docker-compose restart client") | crontab -

echo "✅ Настройка автоматического обновления сертификата завершена" 