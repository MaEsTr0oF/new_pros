#!/bin/bash
set -e

echo "🔍 Проверка API endpoints..."

echo "👉 Проверка работы API для районов..."
curl -s http://localhost:5001/api/districts/1 | jq .

echo "👉 Проверка работы API для услуг..."
curl -s http://localhost:5001/api/services | jq .

echo "✅ Проверка API завершена"
