// Базовая функция для выполнения fetch запросов
const baseUrl = '/api'; // используем относительный URL

// Функция для получения токена из localStorage
const getToken = () => localStorage.getItem('token');

// Общая функция для отправки запросов
async function fetchWithAuth(url: string, options: RequestInit = {}) {
  const token = getToken();
  
  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
    ...options.headers
  };
  
  const response = await fetch(`${baseUrl}${url}`, {
    ...options,
    headers
  });
  
  if (!response.ok) {
    throw new Error(`API Error: ${response.status}`);
  }
  
  // Если ответ пустой, возвращаем { data: null }
  const contentType = response.headers.get('content-type');
  if (contentType && contentType.includes('application/json')) {
    const data = await response.json();
    return { data, status: response.status };
  }
  
  return { data: null, status: response.status };
}

// Экспортируем API методы
export const simpleApi = {
  get: (url: string) => fetchWithAuth(url, { method: 'GET' }),
  post: (url: string, data?: any) => fetchWithAuth(url, { 
    method: 'POST', 
    body: data ? JSON.stringify(data) : undefined
  }),
  put: (url: string, data?: any) => fetchWithAuth(url, { 
    method: 'PUT', 
    body: data ? JSON.stringify(data) : undefined
  }),
  delete: (url: string) => fetchWithAuth(url, { method: 'DELETE' }),
  patch: (url: string, data?: any) => fetchWithAuth(url, { 
    method: 'PATCH', 
    body: data ? JSON.stringify(data) : undefined
  })
};
