#!/bin/bash
echo "Тестирование API /api/districts/1"
curl -v http://escort-server:5001/api/districts/1
echo -e "\n\nТестирование API /api/services"
curl -v http://escort-server:5001/api/services
