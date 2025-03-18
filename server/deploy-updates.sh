#!/bin/bash

# Скрипт для обновления проекта на сервере

# Функция для вывода информационных сообщений
info() {
  echo -e "\e[34m[ИНФО]\e[0m $1"
}

# Функция для вывода сообщений об успехе
success() {
  echo -e "\e[32m[УСПЕХ]\e[0m $1"
}

# Функция для вывода сообщений об ошибках
error() {
  echo -e "\e[31m[ОШИБКА]\e[0m $1"
}

# Создание резервной копии базы данных
info "Создание резервной копии базы данных..."
if [ -f "../backup-db.sh" ]; then
  ../backup-db.sh
  if [ $? -ne 0 ]; then
    error "Не удалось создать резервную копию базы данных"
    error "Продолжаем без резервной копии, будьте осторожны!"
  else
    success "Резервная копия базы данных создана"
  fi
else
  info "Скрипт резервного копирования не найден, пропускаем этот шаг"
fi

# Останавливаем контейнеры
info "Останавливаем контейнеры..."
cd ..
docker-compose down
if [ $? -ne 0 ]; then
  error "Ошибка при остановке контейнеров"
  exit 1
fi
success "Контейнеры остановлены"

# Запускаем только базу данных
info "Запускаем базу данных..."
docker-compose up -d postgres
if [ $? -ne 0 ]; then
  error "Ошибка при запуске базы данных"
  exit 1
fi
success "База данных запущена"
sleep 5

# Установка зависимостей и запуск миграции
info "Установка зависимостей сервера..."
cd server
npm install slugify
npm install

info "Запуск скрипта миграции данных..."
node db-migrate.js
if [ $? -ne 0 ]; then
  error "Ошибка при выполнении скрипта миграции данных"
  info "Продолжаем выполнение, так как ошибка может быть из-за уже примененных миграций"
fi

info "Применение миграций Prisma..."
npx prisma generate
if [ $? -ne 0 ]; then
  error "Ошибка при генерации Prisma клиента"
  info "Продолжаем выполнение"
fi

cd ..

# Сборка новых образов
info "Сборка новых Docker образов..."
docker-compose build
if [ $? -ne 0 ]; then
  error "Ошибка при сборке Docker образов"
  exit 1
fi
success "Docker образы успешно собраны"

# Запуск всех контейнеров
info "Запускаем все контейнеры..."
docker-compose up -d
if [ $? -ne 0 ]; then
  error "Ошибка при запуске контейнеров"
  exit 1
fi
success "Все контейнеры успешно запущены"

# Проверка состояния контейнеров
info "Проверка состояния контейнеров..."
docker-compose ps

info "Проверка логов сервера (последние 20 строк)..."
docker-compose logs --tail=20 server

success "Обновление успешно завершено!"
info "Проверьте работу сайта по адресу: https://eskortvsegorodarfreal.site"
info "Проверьте работу API по адресу: https://eskortvsegorodarfreal.site/api/health"
info "Проверьте работу админ-панели: https://eskortvsegorodarfreal.site/admin"
