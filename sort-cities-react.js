/**
 * Скрипт для сортировки городов в React-компонентах
 */
(function() {
  // Ожидаем загрузку React и ReactDOM
  function waitForReact(callback) {
    const checkInterval = setInterval(() => {
      if (window.React && window.ReactDOM) {
        clearInterval(checkInterval);
        callback();
      }
    }, 100);
    
    // Остановим проверку через 10 секунд, если React не загрузился
    setTimeout(() => {
      clearInterval(checkInterval);
    }, 10000);
  }
  
  // Патчим React-компоненты для сортировки списка городов
  function patchReactComponents() {
    // Сохраняем оригинальные методы React.createElement и Component.setState
    const originalCreateElement = React.createElement;
    
    // Переопределяем React.createElement для перехвата городов
    React.createElement = function(type, props, ...children) {
      if (props && props.children) {
        // Проверяем, содержат ли дочерние элементы список городов
        if (Array.isArray(props.children) && props.children.length > 3) {
          // Ищем признаки списка городов (например, наличие 'Москва', 'Санкт-Петербург')
          const isCityList = props.children.some(child => 
            child && child.props && child.props.children && 
            typeof child.props.children === 'string' && 
            (child.props.children.includes('Москва') || 
             child.props.children.includes('Санкт-Петербург') || 
             child.props.children.includes('Казань'))
          );
          
          if (isCityList) {
            console.log('Найден компонент со списком городов:', props);
            
            // Сортируем список, сохраняя первый элемент (если это заголовок)
            const startIndex = props.children[0].props && props.children[0].props.disabled ? 1 : 0;
            props.children = [
              ...props.children.slice(0, startIndex),
              ...props.children.slice(startIndex).sort((a, b) => {
                const aText = a.props.children;
                const bText = b.props.children;
                return aText.localeCompare(bText, 'ru');
              })
            ];
            
            console.log('Список городов отсортирован в компоненте React');
          }
        }
      }
      
      // Вызываем оригинальный метод
      return originalCreateElement(type, props, ...children);
    };
    
    // Патчим прототип компонента для перехвата setState
    const originalSetState = React.Component.prototype.setState;
    
    React.Component.prototype.setState = function(partialState, callback) {
      if (partialState && partialState.cities && Array.isArray(partialState.cities)) {
        console.log('Перехвачен setState с городами:', partialState.cities);
        partialState.cities.sort((a, b) => a.name.localeCompare(b.name, 'ru'));
        console.log('Города отсортированы в setState');
      }
      
      return originalSetState.call(this, partialState, callback);
    };
    
    console.log('React компоненты патчены для сортировки городов');
  }
  
  // Запускаем патч после загрузки React
  waitForReact(patchReactComponents);
})();
