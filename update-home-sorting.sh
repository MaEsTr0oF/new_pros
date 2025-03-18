#!/bin/bash
# Ищем файл HomePage.tsx
find /root/escort-project/client/src -name "HomePage.tsx" -type f | while read -r file; do
  # Добавляем сортировку по order в useEffect с загрузкой профилей
  sed -i '/setProfiles(response.data);/i \        // Сортируем профили по полю order\n        const sortedProfiles = response.data.sort((a, b) => (a.order || 0) - (b.order || 0));' "$file"
  sed -i 's/setProfiles(response.data);/setProfiles(sortedProfiles);/' "$file"
done
