const express = require('express');
const cors = require('cors');
const app = express();
const port = 5002;

// Включаем middleware
app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Массив городов, уже отсортированный по алфавиту
const citiesList = [
  { id: 53, name: 'Абинск', code: 'abinsk' },
  { id: 42, name: 'Абакан', code: 'abakan' },
  { id: 28, name: 'Альметьевск', code: 'almetevsk' },
  { id: 92, name: 'Амурск', code: 'amursk' },
  { id: 54, name: 'Анапа', code: 'anapa' },
  { id: 77, name: 'Арсеньев', code: 'arsenev' },
  { id: 78, name: 'Артем', code: 'artem' },
  { id: 55, name: 'Армавир', code: 'armavir' },
  { id: 67, name: 'Ачинск', code: 'achinsk' },
  { id: 48, name: 'Барнаул', code: 'barnaul' },
  { id: 3, name: 'Белорецк', code: 'beloretsk' },
  { id: 56, name: 'Белореченск', code: 'belorechensk' },
  { id: 95, name: 'Белогорск', code: 'belogorsk' },
  { id: 50, name: 'Белокуриха', code: 'belokuriha' },
  { id: 49, name: 'Бийск', code: 'bijsk' },
  { id: 4, name: 'Благовещенск', code: 'blagoveshchensk' },
  { id: 68, name: 'Боготол', code: 'bogotol' },
  { id: 29, name: 'Бугульма', code: 'bugulma' },
  { id: 30, name: 'Буинск', code: 'buinsk' },
  { id: 79, name: 'Владивосток', code: 'vladivostok' },
  { id: 27, name: 'Владикавказ', code: 'vladikavkaz' },
  { id: 21, name: 'Волжск', code: 'volzhsk' },
  { id: 17, name: 'Воркута', code: 'vorkuta' },
  { id: 38, name: 'Воткинск', code: 'votkinsk' },
  { id: 39, name: 'Глазов', code: 'glazov' },
  { id: 83, name: 'Георгиевск', code: 'georgievsk' },
  { id: 57, name: 'Геленджик', code: 'gelendzhik' },
  { id: 12, name: 'Горно-Алтайск', code: 'gorno-altajsk' },
  { id: 80, name: 'Дальнереченск', code: 'dalnerechensk' },
  { id: 69, name: 'Дивногорск', code: 'divnogorsk' },
  { id: 58, name: 'Ейск', code: 'ejsk' },
  { id: 31, name: 'Елабуга', code: 'elabuga' },
  { id: 70, name: 'Енисейск', code: 'enisejsk' },
  { id: 84, name: 'Ессентуки', code: 'essentuki' },
  { id: 85, name: 'Желездноводск', code: 'zhelezdnovodsk' },
  { id: 72, name: 'Железногорск', code: 'zheleznogorsk' },
  { id: 40, name: 'Ижевск', code: 'izhevsk' },
  { id: 22, name: 'Йошкар-Ола', code: 'joshkar-ola' },
  { id: 33, name: 'Казань', code: 'kazan' },
  { id: 71, name: 'Канск', code: 'kansk' },
  { id: 44, name: 'Канаш', code: 'kanash' },
  { id: 86, name: 'Кисловодск', code: 'kislovodsk' },
  { id: 93, name: 'Комсомольск-на-Амуре', code: 'komsomolsk-na-amure' },
  { id: 73, name: 'Красноярск', code: 'krasnoyarsk' },
  { id: 59, name: 'Краснодар', code: 'krasnodar' },
  { id: 60, name: 'Кропоткин', code: 'kropotkin' },
  { id: 37, name: 'Кызыл', code: 'kyzyl' },
  { id: 87, name: 'Минеральные воды', code: 'mineralnye-vody' },
  { id: 74, name: 'Минусинск', code: 'minusinsk' },
  { id: 1, name: 'Москва', code: 'moscow' },
  { id: 34, name: 'Набережные Челны', code: 'naberezhnye-chelny' },
  { id: 13, name: 'Нальчик', code: 'nalchik' },
  { id: 81, name: 'Находка', code: 'nahodka' },
  { id: 5, name: 'Нефтекамск', code: 'neftekamsk' },
  { id: 88, name: 'Невинномысск', code: 'nevinnomyssk' },
  { id: 25, name: 'Нерюнгри', code: 'nerungri' },
  { id: 35, name: 'Нижнекамск', code: 'nizhnekamsk' },
  { id: 61, name: 'Новороссийск', code: 'novorossijsk' },
  { id: 45, name: 'Новочебоксарск', code: 'novocheboksarsk' },
  { id: 51, name: 'Новоалтайск', code: 'novoaltajsk' },
  { id: 75, name: 'Норильск', code: 'norilsk' },
  { id: 6, name: 'Октябрьский', code: 'oktabrskij' },
  { id: 16, name: 'Петразаводск', code: 'petrazavodsk' },
  { id: 89, name: 'Пятигорск', code: 'pyatigorsk' },
  { id: 52, name: 'Рубцовск', code: 'rubtsovsk' },
  { id: 23, name: 'Рузаевка', code: 'ruzaevka' },
  { id: 7, name: 'Салават', code: 'salavat' },
  { id: 2, name: 'Санкт-Петербург', code: 'spb' },
  { id: 41, name: 'Сарапул', code: 'sarapul' },
  { id: 24, name: 'Саранск', code: 'saransk' },
  { id: 10, name: 'Северобайкальск', code: 'severobajkalsk' },
  { id: 90, name: 'Светлоград', code: 'svetlograd' },
  { id: 62, name: 'Славянск-на-Кубани', code: 'slavansk-na-kubani' },
  { id: 63, name: 'Сочи', code: 'sochi' },
  { id: 20, name: 'Сосногорск', code: 'sosnogorsk' },
  { id: 43, name: 'Сорск', code: 'sorsk' },
  { id: 91, name: 'Ставрополь', code: 'stavropol' },
  { id: 8, name: 'Стерлитамак', code: 'sterlitamak' },
  { id: 18, name: 'Сыктывкар', code: 'syktyvkar' },
  { id: 64, name: 'Тихорецк', code: 'tihoretsk' },
  { id: 65, name: 'Туапсе', code: 'tuapse' },
  { id: 11, name: 'Улан-Удэ', code: 'ulan-ude' },
  { id: 9, name: 'Уфа', code: 'ufa' },
  { id: 76, name: 'Ужур', code: 'uzhur' },
  { id: 66, name: 'Усть-Лабинск', code: 'ust-labinsk' },
  { id: 82, name: 'Уссурийск', code: 'ussurisk' },
  { id: 19, name: 'Ухта', code: 'uhta' },
  { id: 94, name: 'Хабаровск', code: 'habarovsk' },
  { id: 15, name: 'Черкесск', code: 'cherkessk' },
  { id: 47, name: 'Чебоксары', code: 'cheboksary' },
  { id: 36, name: 'Чистополь', code: 'chistopol' },
  { id: 46, name: 'Цивильск', code: 'tsivilsk' },
  { id: 14, name: 'Элиста', code: 'elista' },
  { id: 26, name: 'Якутск', code: 'yakutsk' }
];

// Районы (статические данные)
const districts = {
  1: ["Центральный", "Северный", "Южный", "Западный", "Восточный"],
  2: ["Центральный", "Адмиралтейский", "Василеостровский", "Калининский"],
  // добавляем для других городов по желанию
};

// Маршрут для списка городов
app.get('/api/cities', (req, res) => {
  console.log('Запрошен список городов');
  // Города уже отсортированы по алфавиту
  res.json(citiesList);
});

// Маршрут для получения районов
app.get('/api/districts/:cityId', (req, res) => {
  const cityId = parseInt(req.params.cityId);
  console.log('Запрошены районы для города:', cityId);
  
  // Возвращаем районы для указанного города, или стандартный набор районов
  const cityDistricts = districts[cityId] || ["Центральный", "Северный", "Южный", "Западный", "Восточный"];
  res.json(cityDistricts);
});

// Маршрут для получения услуг
app.get('/api/services', (req, res) => {
  console.log('Запрошен список услуг');
  const services = [
    "classic", "anal", "massage", "oral", "kisses", 
    "blowjob_with_condom", "blowjob_without_condom",
    "deep_blowjob", "anilingus_to_client", "fisting_to_client"
  ];
  res.json(services);
});

// Маршрут для проверки здоровья сервера
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Запуск сервера
app.listen(port, () => {
  console.log(`Сервер API запущен на порту ${port}`);
  console.log('Поддерживаемые маршруты:');
  console.log(' - /api/cities - список городов');
  console.log(' - /api/districts/:cityId - районы по ID города');
  console.log(' - /api/services - список услуг');
  console.log(' - /api/health - проверка работоспособности');
});
