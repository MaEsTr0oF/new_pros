#!/bin/bash
# Обновляем импорты и экспорты в profileController.ts
sed -i '1s/^/import { moveProfileUp, moveProfileDown } from "\.\/profileOrder";\n/' /root/escort-project/server/src/controllers/profileController.ts
echo 'export { moveProfileUp, moveProfileDown };' >> /root/escort-project/server/src/controllers/profileController.ts

# Заменяем сортировку в getProfiles
sed -i 's/orderBy: {\n.*createdAt: .desc.\n.*}/orderBy: {\n      order: "asc"\n    }/' /root/escort-project/server/src/controllers/profileController.ts
