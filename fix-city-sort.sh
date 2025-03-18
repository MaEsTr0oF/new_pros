#!/bin/bash
# Находим контроллер городов
file=$(find /root/escort-project/server/src/controllers -name "cityController.ts")
if [ -n "$file" ]; then
  # Добавляем сортировку городов по имени
  if grep -q "getCities" "$file"; then
    # Находим функцию getCities и добавляем сортировку
    sed -i '/const cities = await prisma.city.findMany/,/});/ s/});/,\n      orderBy: {\n        name: "asc"\n      }\n    });/' "$file"
  fi
fi
