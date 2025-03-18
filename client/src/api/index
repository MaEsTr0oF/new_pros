import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { API_URL } from '../config';
import { Profile, City, FilterParams } from '../types';

// Создаем базовый инстанс axios
const axiosInstance = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Интерцептор для добавления токена авторизации
axiosInstance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// API для профилей
const profiles = {
  getAll: (cityId?: number, filters?: FilterParams) => {
    const params: any = {};
    if (cityId) params.cityId = cityId;
    if (filters) params.filters = JSON.stringify(filters);
    return axiosInstance.get('/profiles', { params });
  },
  getById: (id: number) => axiosInstance.get(`/profiles/${id}`),
  create: (profile: Profile) => axiosInstance.post('/admin/profiles', profile),
  update: (id: number, profile: Profile) => axiosInstance.put(`/admin/profiles/${id}`, profile),
  delete: (id: number) => axiosInstance.delete(`/admin/profiles/${id}`),
  verify: (id: number) => axiosInstance.patch(`/admin/profiles/${id}/verify`),
  moveUp: (id: number) => axiosInstance.patch(`/admin/profiles/${id}/moveUp`),
  moveDown: (id: number) => axiosInstance.patch(`/admin/profiles/${id}/moveDown`),
};

// API для городов
const cities = {
  getAll: () => axiosInstance.get('/cities'),
  create: (city: City) => axiosInstance.post('/admin/cities', city),
  update: (id: number, city: City) => axiosInstance.put(`/admin/cities/${id}`, city),
  delete: (id: number) => axiosInstance.delete(`/admin/cities/${id}`),
};

// API для авторизации
const auth = {
  login: (username: string, password: string) => 
    axiosInstance.post('/auth/login', { username, password }),
  logout: () => {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user');
  },
  isAuthenticated: () => !!localStorage.getItem('auth_token'),
};

// API для настроек
const settings = {
  getPublic: () => axiosInstance.get('/settings/public'),
  getAll: () => axiosInstance.get('/admin/settings'),
  update: (settings: any) => axiosInstance.put('/admin/settings', settings),
};

// API для районов
const districts = {
  getByCityId: (cityId: number) => axiosInstance.get(`/districts/${cityId}`),
};

// API для услуг
const services = {
  getAll: () => axiosInstance.get('/services'),
};

// Создаем гибридный API-объект, который поддерживает оба стиля:
// 1. Прямые вызовы axios: api.get(), api.post(), api.patch()
// 2. Объектный доступ: api.profiles.getAll(), api.cities.getAll()
interface ApiType extends AxiosInstance {
  profiles: typeof profiles;
  cities: typeof cities;
  auth: typeof auth;
  settings: typeof settings;
  districts: typeof districts;
  services: typeof services;
  axiosInstance: AxiosInstance;
}

// Создаем базовый объект и расширяем его методами и свойствами
const api = axiosInstance as ApiType;

// Добавляем объектные API
api.profiles = profiles;
api.cities = cities;
api.auth = auth;
api.settings = settings;
api.districts = districts;
api.services = services;
api.axiosInstance = axiosInstance;

export { api };
export default api;
