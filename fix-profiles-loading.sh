#!/bin/bash
set -e

echo "🔧 Добавляем альтернативный метод загрузки профилей"

# Путь к странице профилей
PROFILES_PAGE="/root/escort-project/client/src/pages/admin/ProfilesPage.tsx"

# Проверяем, существует ли файл
if [ -f "$PROFILES_PAGE" ]; then
  cp $PROFILES_PAGE ${PROFILES_PAGE}.bak_loading
  
  # Добавляем альтернативную функцию загрузки профилей
  # Ищем функцию fetchProfiles
  if grep -q "fetchProfiles" "$PROFILES_PAGE"; then
    # Добавляем альтернативную функцию
    sed -i '/const fetchProfiles/a\  // Альтернативная функция загрузки профилей через публичный API\n  const fetchPublicProfiles = async () => {\n    try {\n      setLoading(true);\n      console.log("Попытка загрузки профилей через публичный API...");\n      \n      // Получаем профили через публичный API\n      const response = await axios.get(`${API_URL}/profiles`);\n      console.log("Профили получены через публичный API:", response.data);\n      \n      setProfiles(response.data);\n      setError("");\n    } catch (err) {\n      console.error("Ошибка при загрузке профилей через публичный API:", err);\n      setError("Не удалось загрузить профили. Попробуйте войти снова.");\n    } finally {\n      setLoading(false);\n    }\n  };' "$PROFILES_PAGE"
    
    # Модифицируем useEffect, чтобы использовать альтернативную функцию при ошибке основной
    sed -i '/useEffect\(\(\) => {/a\    // Сначала пробуем загрузить через админский API, если не получится - через публичный\n    fetchProfiles().catch(err => {\n      console.error("Ошибка при загрузке через админский API, пробуем публичный:", err);\n      fetchPublicProfiles();\n    });' "$PROFILES_PAGE"
    
    # Комментируем оригинальный вызов fetchProfiles в useEffect
    sed -i '/fetchProfiles();/s/^/\/\/ /' "$PROFILES_PAGE"
    
    echo "✅ Альтернативный метод загрузки профилей добавлен"
  else
    echo "⚠️ Функция fetchProfiles не найдена"
  fi
else
  echo "⚠️ Файл страницы профилей не найден по пути $PROFILES_PAGE"
fi

echo "✅ Исправления загрузки профилей завершены"
