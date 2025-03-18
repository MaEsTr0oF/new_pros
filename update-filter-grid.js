// Изменение стиля ButtonContainer с flex на grid
const fs = require('fs');

// Читаем файл FilterBar.tsx
const filePath = 'client/src/components/FilterBar.tsx';
let content = fs.readFileSync(filePath, 'utf8');

// Найдем определение ButtonContainer
const buttonContainerRegex = /(const ButtonContainer = styled\(Box\)\(\({ theme }\) => \({[^}]*)\}\)\);/s;
const match = content.match(buttonContainerRegex);

if (match) {
  // Заменим стили, изменив flex на grid
  const oldStyle = match[1];
  let newStyle = oldStyle.replace(
    /display: ['"]flex['"],(\s*)/g, 
    "display: 'grid',\n  gridTemplateColumns: 'repeat(auto-fill, minmax(80px, 1fr))',\n  gap: '8px',\n"
  );
  
  // Удаляем лишние flex-стили если они есть
  newStyle = newStyle.replace(/flexWrap: ['"]wrap['"],(\s*)/g, '');
  newStyle = newStyle.replace(/gap: ['"][^'"]*['"],(\s*)/g, '');
  
  // Применяем изменения к файлу
  content = content.replace(buttonContainerRegex, newStyle + '}));');
  fs.writeFileSync(filePath, content);
  console.log('Стили ButtonContainer обновлены на grid');
} else {
  console.log('Не удалось найти ButtonContainer в файле');
  
  // Попробуем найти определение в другом формате
  // Если определение выглядит иначе, можем добавить здесь альтернативный поиск
}
