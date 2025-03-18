#!/bin/bash
# Находим функцию getProfiles в контроллере и меняем сортировку
sed -i '
/export const getProfiles/,/orderBy:/ {
  s/orderBy: {[^}]*}/orderBy: {\n      order: "asc"\n    }/
}' /root/escort-project/server/src/controllers/profileController.ts
