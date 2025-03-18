#!/bin/bash
# Добавляем маршруты для перемещения профилей после маршрута verify
sed -i '/app.patch.*\/api\/admin\/profiles\/:id\/verify.*/a app.patch("/api/admin/profiles/:id/moveUp", profileController.moveProfileUp);\napp.patch("/api/admin/profiles/:id/moveDown", profileController.moveProfileDown);' /root/escort-project/server/src/index.ts
