import { api } from './utils/api';

// Экспорт API клиента для обратной совместимости
export const apiClient = api;

// Профили
export const getProfiles = () => api.get('/admin/profiles');
export const createProfile = (data: any) => api.post('/admin/profiles', data);
export const updateProfile = (id: number, data: any) => api.put(`/admin/profiles/${id}`, data);
export const deleteProfile = (id: number) => api.delete(`/admin/profiles/${id}`);
export const moveProfileUp = (id: number) => api.post(`/admin/profiles/${id}/move-up`);
export const moveProfileDown = (id: number) => api.post(`/admin/profiles/${id}/move-down`);
export const verifyProfile = (id: number) => api.patch(`/admin/profiles/${id}/verify`);

// Города
export const getCities = () => api.get('/cities');
export const createCity = (data: any) => api.post('/admin/cities', data);
export const updateCity = (id: number, data: any) => api.put(`/admin/cities/${id}`, data);
export const deleteCity = (id: number) => api.delete(`/admin/cities/${id}`);
export const sortCitiesAlphabetically = () => api.post('/admin/cities/sort-alphabetically');

// Настройки
export const getSettings = () => api.get('/admin/settings');
export const updateSettings = (data: any) => api.put('/admin/settings', data);

// Экспорт API по умолчанию
export default api;
