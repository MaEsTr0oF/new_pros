#!/bin/bash
# Удаляем дублирующиеся маршруты, если они есть
sed -i '/app.patch.*\/api\/admin\/profiles\/:id\/moveUp/d' /root/escort-project/server/src/index.ts
sed -i '/app.patch.*\/api\/admin\/profiles\/:id\/moveDown/d' /root/escort-project/server/src/index.ts

# Добавляем маршруты после verify
sed -i '/app.patch.*\/api\/admin\/profiles\/:id\/verify/a app.patch("/api/admin/profiles/:id/moveUp", profileController.moveProfileUp);\napp.patch("/api/admin/profiles/:id/moveDown", profileController.moveProfileDown);' /root/escort-project/server/src/index.ts
