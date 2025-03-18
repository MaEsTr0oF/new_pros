#!/bin/bash
echo "🔄 Восстанавливаем заглушку..."
docker cp /root/escort-project/backup-placeholder/index.html escort-client:/usr/share/nginx/html/index.html
docker exec escort-client nginx -s reload
echo "✅ Заглушка восстановлена"
