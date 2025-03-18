#!/bin/bash
set -e

echo "🔧 Исправляем проблемы с авторизацией"

# Путь к API файлу
API_FILE="/root/escort-project/client/src/api/index.ts"
LOGIN_FILE="/root/escort-project/client/src/pages/admin/LoginPage.tsx"

# Создаем резервную копию файла API
if [ -f "$API_FILE" ]; then
  cp $API_FILE ${API_FILE}.bak_auth
  
  # Улучшаем функцию получения токена и заголовков авторизации
  sed -i 's/const getToken = () => localStorage.getItem(/const getToken = () => {\n  const token = localStorage.getItem(/g' $API_FILE
  sed -i 's/getToken = () => {/getToken = () => {\n  console.log("Getting auth token:", token);\n  return token;\n}/g' $API_FILE
  sed -i 's/export const getAuthHeaders = () => {/export const getAuthHeaders = () => {\n  const token = getToken();\n  console.log("Auth headers with token:", token ? "Bearer " + token.substring(0, 10) + "..." : "No token");\n  return {/g' $API_FILE
  
  echo "✅ API файл улучшен с дополнительным логированием авторизации"
else
  echo "⚠️ API файл не найден по пути $API_FILE"
fi

# Улучшаем страницу логина, чтобы гарантировать сохранение токена
if [ -f "$LOGIN_FILE" ]; then
  cp $LOGIN_FILE ${LOGIN_FILE}.bak_auth
  
  # Добавляем дополнительное логирование и проверку сохранения токена
  sed -i '/localStorage.setItem(/a\        console.log("Token saved to localStorage:", response.data.token.substring(0, 10) + "...");\n        // Проверяем, что токен действительно сохранен\n        const savedToken = localStorage.getItem("token");\n        if (!savedToken) {\n          console.error("Ошибка: Токен не был сохранен в localStorage!");\n          setError("Ошибка сохранения токена авторизации");\n          return;\n        }' $LOGIN_FILE
  
  echo "✅ Страница логина улучшена с проверкой сохранения токена"
else
  echo "⚠️ Файл страницы логина не найден по пути $LOGIN_FILE"
fi

echo "✅ Исправления авторизации завершены"
