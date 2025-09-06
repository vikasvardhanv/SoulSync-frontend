// frontend/src/services/api.ts
import axios, { AxiosError } from 'axios';
import toast from 'react-hot-toast';

// Determine API URL based on environment
const getApiUrl = () => {
  // Check if we're in development mode
  if (import.meta.env.DEV) {
    return import.meta.env.VITE_API_URL || 'http://localhost:5001/api';
  }
  
  // In production, use the backend domain
  return import.meta.env.VITE_API_URL || 'https://soulsync.solutions/api';
};

const API_BASE_URL = getApiUrl();

console.log('🌐 API Base URL:', API_BASE_URL);

const api = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: false,
  headers: {
    'Content-Type': 'application/json'
  },
  timeout: 30000 // 30 second timeout
});

// Add auth token to requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // Log outgoing requests in development
    if (import.meta.env.DEV) {
      console.log('📤 API Request:', {
        method: config.method?.toUpperCase(),
        url: config.url,
        hasAuth: !!token,
        data: config.data ? Object.keys(config.data) : null
      });
    }
    
    return config;
  },
  (error) => {
    console.error('❌ Request interceptor error:', error);
    return Promise.reject(error);
  }
);

// Enhanced response interceptor with better error handling
api.interceptors.response.use(
  (response) => {
    // Log successful responses in development
    if (import.meta.env.DEV) {
      console.log('📥 API Response:', {
        method: response.config.method?.toUpperCase(),
        url: response.config.url,
        status: response.status,
        success: response.data?.success
      });
    }
    return response;
  },
  async (error: AxiosError<any>) => {
    const original = error.config;
    const status = error.response?.status;
    const message = error.response?.data?.message || 'An error occurred';
    const errorType = error.response?.data?.error?.type;
    const suggestion = error.response?.data?.error?.suggestion || '';

    console.error('❌ API Error:', { 
      status, 
      message, 
      errorType, 
      url: original?.url,
      method: original?.method?.toUpperCase()
    });

    // Handle timeout errors
    if (error.code === 'ECONNABORTED' || error.message?.includes('timeout')) {
      toast.error('Request timed out. Please check your connection and try again.', {
        duration: 5000
      });
      return Promise.reject(error);
    }

    // Handle network errors
    if (!error.response) {
      toast.error('Network error. Please check your internet connection.', {
        duration: 5000
      });
      return Promise.reject(error);
    }

    // Handle specific HTTP status codes
    switch (status) {
      case 400:
        // Bad request - validation errors
        if (error.response?.data?.errors) {
          // Multiple validation errors
          const errorMessages = error.response.data.errors
            .map((err: any) => err.message || err.msg)
            .join(', ');
          toast.error(`Validation error: ${errorMessages}`, { duration: 6000 });
        } else {
          toast.error(message + (suggestion ? ` ${suggestion}` : ''), { duration: 5000 });
        }
        break;

      case 401:
        // Unauthorized - handle based on context
        const isAuthFlow = window.location.pathname.includes('/signup') || 
                          window.location.pathname.includes('/login') || 
                          window.location.pathname.includes('/register');
        const isOptionalAuth = original?.url?.includes('/images/upload') || 
                              original?.url?.includes('/users/potential-matches');
        
        if (isAuthFlow || isOptionalAuth) {
          // For signup flow and optional auth endpoints, just log the error
          console.warn('⚠️ Auth error during signup/optional endpoint:', { 
            url: original?.url, 
            message 
          });
        } else {
          // Normal 401 handling for authenticated routes
          toast.error('Session expired. Please log in again.', { duration: 5000 });
          
          if (!original?._retry) {
            original._retry = true;
            localStorage.removeItem('accessToken');
            localStorage.removeItem('refreshToken');
            
            // Redirect to login after short delay
            setTimeout(() => {
              window.location.href = '/login';
            }, 1500);
          }
        }
        break;

      case 403:
        // Forbidden
        toast.error('Access denied. ' + (suggestion || 'You don\'t have permission to perform this action.'), {
          duration: 5000
        });
        break;

      case 404:
        // Not found
        if (original?.url?.includes('/api/')) {
          toast.error('Resource not found. Please try again.', { duration: 4000 });
        }
        break;

      case 409:
        // Conflict
        toast.error(message, { duration: 5000 });
        break;

      case 413:
        // Payload too large
        toast.error(`${message} ${suggestion || 'Please reduce the file size and try again.'}`, {
          duration: 6000
        });
        break;

      case 429:
        // Too many requests
        toast.error('Too many requests. Please slow down and try again in a moment.', {
          duration: 6000
        });
        break;

      case 500:
      case 502:
      case 503:
      case 504:
        // Server errors
        toast.error('Server error. Our team has been notified. Please try again later.', {
          duration: 6000
        });
        break;

      default:
        // Generic error message
        toast.error(message || 'An unexpected error occurred. Please try again.', {
          duration: 5000
        });
    }

    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  register: (data: any) => api.post('/auth/register', data),
  login: (data: { email: string; password: string }) => api.post('/auth/login', data),
  logout: (data: { refreshToken: string; logoutAll?: boolean }) => api.post('/auth/logout', data),
  forgotPassword: (data: { email: string }) => api.post('/auth/forgot-password', data),
  resetPassword: (data: { token: string; userId: string; newPassword: string }) => 
    api.post('/auth/reset-password', data),
  changePassword: (data: { currentPassword: string; newPassword: string }) => 
    api.put('/auth/change-password', data),
  verifyEmail: (token: string) => api.get(`/auth/verify-email?token=${token}`),
  resendVerification: () => api.post('/auth/resend-verification'),
  refreshToken: (data: { refreshToken: string }) => api.post('/auth/refresh', data),
  getMe: () => api.get('/auth/me'),
  deleteAccount: (data: { password: string; confirmation: string }) => 
    api.delete('/auth/delete-account', { data }),
  updateProfile: (data: any) => api.put('/users/profile', data),
};

// Images API
export const imagesAPI = {
  uploadSingle: (formData: FormData, onProgress?: (progress: number) => void) => {
    return api.post('/images/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      onUploadProgress: (progressEvent) => {
        if (onProgress && progressEvent.total) {
          const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
          onProgress(progress);
        }
      },
      timeout: 60000, // 60 second timeout for large files
    });
  },
  uploadMultiple: (formData: FormData, onProgress?: (progress: number) => void) => {
    return api.post('/images/upload-multiple', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      onUploadProgress: (progressEvent) => {
        if (onProgress && progressEvent.total) {
          const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
          onProgress(progress);
        }
      },
      timeout: 120000, // 2 minute timeout for multiple files
    });
  },
  deletePhoto: (data: { imageId: string }) => api.delete('/images/delete', { data }),
  reorderPhotos: (data: { photoUrls: string[] }) => api.put('/images/reorder', data),
  testConnection: () => api.get('/images/test'),
};

// Matches API
export const matchesAPI = {
  getMatches: () => api.get('/matches'),
  createMatch: (data: { matchedUserId: string; compatibilityScore: number }) => 
    api.post('/matches', data),
  updateMatchStatus: (matchId: string, data: { status: string }) => 
    api.put(`/matches/${matchId}/status`, data),
  getMatchDetails: (matchId: string) => api.get(`/matches/${matchId}`),
  getPotentialMatches: (params?: { limit?: number; offset?: number }) => 
    api.get('/users/matches', { params }),
  getPendingMatches: () => api.get('/matches/pending'),
  getAcceptedMatches: () => api.get('/matches/accepted'),
};

// Messages API
export const messagesAPI = {
  getConversations: () => api.get('/messages/conversations'),
  getConversation: (userId: string, params?: { limit?: number; offset?: number }) => 
    api.get(`/messages/conversation/${userId}`, { params }),
  sendMessage: (data: { receiverId: string; content: string }) => 
    api.post('/messages', data),
  markAsRead: (senderId: string) => api.put(`/messages/read/${senderId}`),
  getUnreadCount: () => api.get('/messages/unread/count'),
  deleteMessage: (messageId: string) => api.delete(`/messages/${messageId}`),
};

// Users API
export const usersAPI = {
  getProfile: () => api.get('/users/profile'),
  updateProfile: (data: any) => api.put('/users/profile', data),
  getPotentialMatches: (params?: { limit?: number; offset?: number }) => 
    api.get('/users/matches', { params }),
  getMyMatches: () => api.get('/users/matches/my'),
  deleteAccount: () => api.delete('/users/account'),
};

// Payments API
export const paymentsAPI = {
  // Get available currencies
  getCurrencies: () => api.get('/payments/currencies'),
  
  // Estimate payment
  estimatePayment: (data: {
    amount: number;
    from_currency: string;
    to_currency: string;
  }) => api.post('/payments/estimate', data),
  
  // Create payment
  createPayment: (data: {
    price_amount: number;
    price_currency: string;
    pay_currency: string;
    order_description: string;
  }) => api.post('/payments/create', data),
  
  // Get payment status
  getPaymentStatus: (paymentId: string) => api.get(`/payments/status/${paymentId}`),
  
  // Create subscription payment
  createSubscription: (data: {
    plan: 'premium' | 'gold';
    duration: 'monthly' | 'yearly';
    payment_method: 'crypto' | 'card';
  }) => api.post('/payments/subscription', data),
  
  // Get payment history
  getPaymentHistory: (params?: { page?: number; limit?: number }) => 
    api.get('/payments/history', { params }),
  
  // NOWPayments specific methods
  createNOWPayments: (data: {
    amount: number;
    currency: string;
    description: string;
  }) => api.post('/payments/nowpayments/create', data),
};

// Subscriptions API
export const subscriptionsAPI = {
  getMySubscription: () => api.get('/subscriptions/me'),
  createSubscription: (data: {
    plan: 'premium' | 'vip';
    paypalSubscriptionId?: string;
  }) => api.post('/subscriptions', data),
  cancelSubscription: () => api.put('/subscriptions/cancel'),
  getSubscriptionHistory: () => api.get('/subscriptions/history'),
  checkPremiumStatus: () => api.get('/subscriptions/premium/check'),
};

// Questions API
export const questionsAPI = {
  getQuestions: (params?: {
    category?: string;
    limit?: number;
    offset?: number;
    weight?: number;
  }) => api.get('/questions', { params }),
  
  getQuestionById: (id: string) => api.get(`/questions/${id}`),
  
  getRandomQuestions: (count: number, params?: {
    category?: string;
    exclude?: string[];
  }) => api.get(`/questions/random/${count}`, { params }),
  
  submitAnswer: (questionId: string, data: { answer: any }) => 
    api.post(`/questions/${questionId}/answer`, data),
  
  getMyAnswers: () => api.get('/questions/answers/me'),
  
  getQuestionsByCategory: (category: string) => 
    api.get(`/questions/category/${category}`),
};

// Analytics API (for admin/user insights)
export const analyticsAPI = {
  getUserStats: () => api.get('/analytics/user-stats'),
  getMatchingStats: () => api.get('/analytics/matching-stats'),
  getEngagementStats: () => api.get('/analytics/engagement'),
};

// Admin API (for admin panel)
export const adminAPI = {
  getUsers: (params?: { page?: number; limit?: number; search?: string }) => 
    api.get('/admin/users', { params }),
  getUserDetails: (userId: string) => api.get(`/admin/users/${userId}`),
  updateUser: (userId: string, data: any) => api.put(`/admin/users/${userId}`, data),
  deleteUser: (userId: string) => api.delete(`/admin/users/${userId}`),
  getSystemStats: () => api.get('/admin/stats'),
  getPayments: (params?: { page?: number; limit?: number }) => 
    api.get('/admin/payments', { params }),
  getReports: () => api.get('/admin/reports'),
};

export default api;

export const resolveImageUrl = (img: any): string => {
  if (!img) return '';
  if (typeof img === 'string') return img;
  return img?.signedUrl || img?.imageUrl || '';
};

export const getSignedImageUrl = resolveImageUrl;
