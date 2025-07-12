import axios from 'axios';

const api = axios.create({
  baseURL:'http://localhost:5000/api/v1',
  withCredentials: true,
});

// 🔑 AUTH ROUTES
export const markAllMentionsViewed = () =>api.patch('/auth/mentions/markAllViewed');
export const signup = (data) => api.post('/auth/signup', data);
export const loginWeb = (data) => api.post('/auth/login/web', data);
export const loginMobile = (data) => api.post('/auth/login/mobile', data);
export const logout = () => api.post('/auth/logout');
export const getMe = () => api.get('/auth/me');

// 📝 QUESTION ROUTES
export const createQuestion = (data) => api.post('/questions', data);
export const addAnswer = (questionId, data) => api.post(`/questions/${questionId}/answers`, data);
export const upvoteAnswer = (answerId) => api.post(`/answers/${answerId}/upvote`);
export const downvoteAnswer = (answerId) => api.post(`/answers/${answerId}/downvote`);
export const getAllQuestions = () => api.get('/questions');
export const getQuestionById = (questionId) => api.get(`/questions/${questionId}`);
export const searchQuestions = (query, page = 1, limit = 10) => api.get('/questions/search', { params: { query, page, limit } });
export const getPaginatedQuestions = (page = 1, limit = 10, sortBy = 'new') => api.get('/dashboard/questions', { params: { page, limit, sortBy } });

export default api;
