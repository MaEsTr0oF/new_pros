#!/bin/sh
# Обновление метатегов в index.html

# Путь к файлу
FILE=/usr/share/nginx/html/index.html

# Замена title
sed -i 's/<title>React App<\/title>/<title>Эскорт услуги в России | Шлюхи, проститутки, куртизанки<\/title>/' $FILE

# Замена мета-описания
sed -i 's/<meta name="description" content="Web site created using create-react-app" \/>/<meta name="description" content="Эскорт услуги в России. Шлюхи, проститутки, куртизанки, женщины древнейшей профессии. VIP индивидуалки и девушки по вызову." \/>/' $FILE

# Добавление Open Graph тегов перед закрытием head, если их еще нет
if ! grep -q 'og:title' $FILE; then
  sed -i 's/<\/head>/<!-- Open Graph Tags -->\n<meta property="og:title" content="Эскорт услуги в России | Шлюхи, проститутки, куртизанки" \/>\n<meta property="og:description" content="Эскорт услуги в России. Шлюхи, проститутки, куртизанки, женщины древнейшей профессии. VIP индивидуалки и девушки по вызову." \/>\n<meta property="og:type" content="website" \/>\n<meta property="og:url" content="https:\/\/eskortvsegorodarfreal.site\/" \/>\n<meta property="og:site_name" content="Эскорт услуги в России" \/>\n<\/head>/' $FILE
fi

echo "Метаданные в index.html обновлены"
