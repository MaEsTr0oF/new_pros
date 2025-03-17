#!/bin/bash

echo "🛠 Настройка Linux-сервера для запуска проекта"

# Обновление пакетов
echo "📦 Обновление списка пакетов..."
apt-get update

# Установка необходимых пакетов
echo "📦 Установка необходимых пакетов..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    ufw \
    nginx \
    dnsutils

# Установка Docker
echo "🐳 Установка Docker..."
if ! [ -x "$(command -v docker)" ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
    echo "✅ Docker успешно установлен"
else
    echo "✅ Docker уже установлен"
fi

# Установка Docker Compose
echo "🐙 Установка Docker Compose..."
if ! [ -x "$(command -v docker-compose)" ]; then
    # Получаем последнюю версию Docker Compose из GitHub
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose успешно установлен"
else
    echo "✅ Docker Compose уже установлен"
fi

# Настройка брандмауэра
echo "🔥 Настройка брандмауэра (UFW)..."
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 5001
echo "y" | ufw enable

# Создание директории для резервных копий
echo "📁 Создание директории для резервных копий..."
mkdir -p ./backups

# Установка прав на запуск скриптов
echo "🔐 Установка прав на запуск скриптов..."
chmod +x deploy.sh
chmod +x restart.sh
chmod +x backup.sh
chmod +x restore.sh
chmod +x setup-ssl.sh

# Проверка DNS-настройки
echo "🌐 Проверка DNS-настройки для домена eskortvsegorodarfreal.site..."
host_ip=$(curl -s ifconfig.me)
dns_ip=$(dig +short eskortvsegorodarfreal.site | head -n1)

if [ -n "$dns_ip" ]; then
    if [ "$host_ip" = "$dns_ip" ]; then
        echo "✅ IP-адрес сервера соответствует DNS записи: $host_ip"
    else
        echo "⚠️ IP-адрес сервера ($host_ip) не соответствует DNS записи ($dns_ip)"
        echo "⚠️ Проверьте настройки DNS для домена eskortvsegorodarfreal.site"
    fi
else
    echo "⚠️ Не удалось получить IP-адрес из DNS записей"
    echo "⚠️ Проверьте настройки DNS для домена eskortvsegorodarfreal.site"
fi

echo "✅ Настройка сервера завершена успешно!"
echo "⚠️ Необходимо перезайти в систему для применения изменений группы docker"
echo "🚀 После этого запустите ./deploy.sh для развертывания проекта"
echo "🔒 Для настройки SSL-сертификата запустите ./setup-ssl.sh после развертывания" 