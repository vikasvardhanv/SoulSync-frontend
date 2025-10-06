// frontend/src/stores/authStore.ts
import { create } from 'zustand';
import { authAPI } from '../services/api';

interface User {
  id: string;
  email: string;
  name: string;
  age?: number;
  bio?: string;
  location?: string;
  city?: string;
  state?: string;
  country?: string;
  latitude?: number;
  longitude?: number;
  gender?: string;
  lookingFor?: string;
  interests?: string[];
  photos?: string[];
  isVerified?: boolean;
  isActive?: boolean;
  personalityScore?: number;
  questionsAnswered?: number;
}

interface Subscription {
  id: string;
  plan: string;
  status: string;
  expiresAt: string;
  createdAt: string;
}

interface AuthState {
  user: User | null;
  loading: boolean;
  error: string | null;
  isAuthenticated: boolean;
  
  // Actions
  signUp: (credentials: {
    email: string;
    password: string;
    name: string;
    age: number;
    bio?: string;
    location?: string;
    interests?: string[];
    photos?: string[];
  }) => Promise<void>;
  
  signIn: (credentials: { 
    email: string; 
    password: string; 
  }) => Promise<void>;
  
  signOut: () => Promise<void>;
  checkAuth: () => Promise<void>;
  
  updateProfile: (updates: Partial<User>) => Promise<void>;
  updateUser: (user: Partial<User>) => void;
  
  verifyEmail: (token: string) => Promise<void>;
  resendVerification: () => Promise<void>;
  
  forgotPassword: (email: string) => Promise<void>;
  resetPassword: (token: string, userId: string, newPassword: string) => Promise<void>;
  changePassword: (currentPassword: string, newPassword: string) => Promise<void>;
  
  clearError: () => void;
  
  // Token management
  refreshToken: () => Promise<boolean>;
  isTokenValid: () => boolean;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  loading: true,
  error: null,
  isAuthenticated: false,

  signUp: async (credentials) => {
    set({ loading: true, error: null });
    
    try {
      console.log('🚀 Starting signup process with:', {
        ...credentials,
        password: '[REDACTED]',
        photos: credentials.photos ? `${credentials.photos.length} photos` : 'no photos'
      });

      const response = await authAPI.register(credentials);
      
      console.log('📥 Signup API response:', {
        success: response.data.success,
        hasTokens: !!response.data.data?.tokens,
        hasUser: !!response.data.data?.user,
        message: response.data.message
      });
      
      if (response.data.success) {
        // Store tokens if provided (some registrations may require email verification first)
        const tokens = response.data.data?.tokens;
        if (tokens?.accessToken) {
          localStorage.setItem('accessToken', tokens.accessToken);
          console.log('✅ Access token stored');
        }
        if (tokens?.refreshToken) {
          localStorage.setItem('refreshToken', tokens.refreshToken);
          console.log('✅ Refresh token stored');
        }
        
        const userData = response.data.data.user;
        const isAuthenticated = !!tokens?.accessToken;
        
        set({ 
          user: userData, 
          loading: false, 
          isAuthenticated,
          error: null 
        });
        
        console.log('✅ Signup successful:', {
          userId: userData?.id,
          isAuthenticated,
          isVerified: userData?.isVerified
        });
        
        // Success message
        if (!userData?.isVerified) {
          console.log('📧 Email verification required');
        }
      } else {
        throw new Error(response.data.message || 'Signup failed');
      }
    } catch (error: any) {
      console.error('❌ Signup error:', error);
      
      const errorMessage = error.response?.data?.message || 
                          error.message || 
                          'Signup failed. Please try again.';
      
      // Check for specific error types
      let specificError = errorMessage;
      if (error.response?.status === 409) {
        specificError = 'This email is already registered. Please try logging in instead.';
      } else if (error.response?.status === 400) {
        specificError = 'Please check your information and try again.';
      } else if (error.response?.status === 413) {
        specificError = 'Your photos are too large. Please compress them and try again.';
      }
      
      set({ 
        error: specificError,
        loading: false,
        user: null,
        isAuthenticated: false
      });
      
      throw error;
    }
  },

  signIn: async (credentials) => {
    set({ loading: true, error: null });
    
    try {
      console.log('🚀 Starting signin process for:', credentials.email);

      const response = await authAPI.login(credentials);
      
      console.log('📥 Signin API response:', {
        success: response.data.success,
        hasTokens: !!response.data.data?.tokens,
        hasUser: !!response.data.data?.user,
        message: response.data.message
      });
      
      if (response.data.success) {
        // Store tokens
        const tokens = response.data.data.tokens;
        if (tokens?.accessToken && tokens?.refreshToken) {
          localStorage.setItem('accessToken', tokens.accessToken);
          localStorage.setItem('refreshToken', tokens.refreshToken);
          console.log('✅ Auth tokens stored');
        } else {
          console.warn('⚠️ Incomplete token data received');
        }
        
        const userData = response.data.data.user;
        set({ 
          user: userData, 
          loading: false,
          isAuthenticated: true,
          error: null
        });
        
        console.log('✅ Signin successful:', {
          userId: userData?.id,
          isVerified: userData?.isVerified
        });
      } else {
        throw new Error(response.data.message || 'Login failed');
      }
    } catch (error: any) {
      console.error('❌ Signin error:', error);
      
      const errorMessage = error.response?.data?.message || 
                          error.message || 
                          'Login failed. Please try again.';
      
      // Check for specific error types
      let specificError = errorMessage;
      if (error.response?.status === 401) {
        specificError = 'Invalid email or password. Please check your credentials.';
      } else if (error.response?.status === 404) {
        specificError = 'Account not found. Please check your email or create a new account.';
      } else if (error.response?.status === 403) {
        specificError = 'Account is disabled. Please contact support.';
      }
      
      set({ 
        error: specificError,
        loading: false,
        user: null,
        isAuthenticated: false
      });
      
      throw error;
    }
  },  signOut: async () => {
    set({ loading: true, error: null });
    
    try {
      const refreshToken = localStorage.getItem('refreshToken');
      if (refreshToken) {
        await authAPI.logout({ refreshToken });
      }
    } catch (error) {
      console.error('Logout API error:', error);
      // Continue with logout even if API call fails
    } finally {
      // Always clear local storage and state
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      
      set({ 
        user: null, 
        loading: false,
        isAuthenticated: false,
        error: null
      });
    }
  },

  checkAuth: async () => {
    const token = localStorage.getItem('accessToken');
    
    if (!token) {
      console.log('🔍 No access token found, user not authenticated');
      set({ 
        user: null, 
        loading: false,
        isAuthenticated: false 
      });
      return;
    }

    set({ loading: true, error: null });
    
    try {
      console.log('🔍 Checking authentication status...');
      const response = await authAPI.getMe();
      
      console.log('📥 Auth check response:', {
        success: response.data.success,
        hasUser: !!response.data.data?.user,
        message: response.data.message
      });
      
      if (response.data.success) {
        const userData = response.data.data.user;
        
        set({ 
          user: userData, 
          loading: false,
          isAuthenticated: true,
          error: null
        });
        
        console.log('✅ Auth check successful:', {
          userId: userData?.id,
          isVerified: userData?.isVerified
        });
      } else {
        throw new Error('Invalid response from server');
      }
    } catch (error: any) {
      console.error('❌ Auth check error:', error);
      
      // If it's a 401 error, try to refresh the token
      if (error.response?.status === 401) {
        console.log('🔄 Access token expired, attempting refresh...');
        
        try {
          const refreshSuccess = await get().refreshToken();
          
          if (refreshSuccess) {
            console.log('✅ Token refresh successful, retrying auth check...');
            // Retry auth check after successful refresh
            try {
              const retryResponse = await authAPI.getMe();
              if (retryResponse.data.success) {
                const userData = retryResponse.data.data.user;
                set({ 
                  user: userData, 
                  loading: false,
                  isAuthenticated: true,
                  error: null
                });
                console.log('✅ Retry auth check successful');
                return;
              }
            } catch (retryError) {
              console.error('❌ Retry auth check failed:', retryError);
            }
          }
        } catch (refreshError) {
          console.error('❌ Token refresh failed:', refreshError);
        }
      }
      
      // Clear auth state on any auth failure
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      
      set({ 
        user: null, 
        loading: false,
        isAuthenticated: false,
        error: null // Don't show error for auth check failures
      });
      
      console.log('🚪 Authentication cleared due to error');
    }
  },

  updateProfile: async (updates) => {
    const currentUser = get().user;
    if (!currentUser) {
      throw new Error('No user logged in');
    }

    set({ loading: true, error: null });
    
    try {
      const response = await authAPI.updateProfile(updates);
      
      if (response?.data.success) {
        const updatedUser = { ...currentUser, ...response.data.data.user };
        
        set({ 
          user: updatedUser, 
          loading: false,
          error: null
        });
      } else {
        throw new Error(response?.data.message || 'Profile update failed');
      }
    } catch (error: any) {
      console.error('Profile update error:', error);
      
      const errorMessage = error.response?.data?.message || 
                          error.message || 
                          'Profile update failed';
      
      set({ 
        error: errorMessage,
        loading: false 
      });
      
      throw error;
    }
  },

  verifyEmail: async (token: string) => {
    set({ loading: true, error: null });
    
    try {
      const response = await authAPI.verifyEmail(token);
      
      if (response.data.success) {
        // Update user verification status if user is logged in
        const currentUser = get().user;
        if (currentUser) {
          set({
            user: { ...currentUser, isVerified: true },
            loading: false,
            error: null
          });
        } else {
          set({ loading: false, error: null });
        }
      } else {
        throw new Error(response.data.message || 'Email verification failed');
      }
    } catch (error: any) {
      console.error('Email verification error:', error);
      
      const errorMessage = error.response?.data?.message || 
                          error.message || 
                          'Email verification failed';
      
      set({ 
        error: errorMessage,
        loading: false 
      });
      
      throw error;
    }
  },

  resendVerification: async () => {
    set({ loading: true, error: null });
    
    try {
      const response = await authAPI.resendVerification();
      
      if (response.data.success) {
        set({ loading: false, error: null });
      } else {
        throw new Error(response.data.message || 'Failed to resend verification email');
      }
    } catch (error: any) {
      console.error('Resend verification error:', error);
      
      const errorMessage = error.response?.data?.message || 
                          error.message || 
                          'Failed to resend verification email';
      
      set({ 
        error: errorMessage,
        loading: false 
      });
      
      throw error;
    }
  },

  forgotPassword: async (email: string) => {
    set({ loading: true, error: null });
    
    try {
      const response = await authAPI.forgotPassword({ email });
      
      if (response.data.success) {
        set({ loading: false, error: null });
      } else {
        throw new Error(response.data.message || 'Failed to send reset email');
      }
    } catch (error: any) {
      console.error('Forgot password error:', error);
      
      const errorMessage = error.response?.data?.message || 
                          error.message || 
                          'Failed to send reset email';
      
      set({ 
        error: errorMessage,
        loading: false 
      });
      
      throw error;
    }
  },

  resetPassword: async (token: string, userId: string, newPassword: string) => {
    set({ loading: true, error: null });
    
    try {
      const response = await authAPI.resetPassword({ token, userId, newPassword });
      
      if (response.data.success) {
        set({ loading: false, error: null });
      } else {
        throw new Error(response.data.message || 'Password reset failed');
      }
    } catch (error: any) {
      console.error('Reset password error:', error);
      
      const errorMessage = error.response?.data?.message || 
                          error.message || 
                          'Password reset failed';
      
      set({ 
        error: errorMessage,
        loading: false 
      });
      
      throw error;
    }
  },

  changePassword: async (currentPassword: string, newPassword: string) => {
    set({ loading: true, error: null });
    
    try {
      const response = await authAPI.changePassword({ currentPassword, newPassword });
      
      if (response.data.success) {
        set({ loading: false, error: null });
      } else {
        throw new Error(response.data.message || 'Password change failed');
      }
    } catch (error: any) {
      console.error('Change password error:', error);
      
      const errorMessage = error.response?.data?.message || 
                          error.message || 
                          'Password change failed';
      
      set({ 
        error: errorMessage,
        loading: false 
      });
      
      throw error;
    }
  },

  refreshToken: async (): Promise<boolean> => {
    const refreshToken = localStorage.getItem('refreshToken');
    
    if (!refreshToken) {
      return false;
    }

    try {
      const response = await authAPI.refreshToken({ refreshToken });
      
      if (response.data.success) {
        const { accessToken, refreshToken: newRefreshToken } = response.data.data.tokens;
        
        // Store new tokens
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('refreshToken', newRefreshToken);
        
        return true;
      } else {
        return false;
      }
    } catch (error: any) {
      console.error('Token refresh error:', error);
      
      // Clear invalid refresh token
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      
      set({ 
        user: null,
        isAuthenticated: false,
        error: null
      });
      
      return false;
    }
  },

  isTokenValid: (): boolean => {
    const token = localStorage.getItem('accessToken');
    if (!token) return false;

    try {
      // Basic token validation (you might want to decode JWT and check expiry)
      const tokenParts = token.split('.');
      if (tokenParts.length !== 3) return false;
      
      // You can add more sophisticated validation here
      // For now, just check if token exists and has proper format
      return true;
    } catch {
      return false;
    }
  },

  updateUser: (userData: Partial<User>) => {
    const currentUser = get().user;
    if (currentUser) {
      set({ user: { ...currentUser, ...userData } });
    }
  },

  clearError: () => {
    set({ error: null });
  },
}));

// Initialize auth check when the store is created
let isInitialized = false;

if (!isInitialized) {
  isInitialized = true;
  
  // Check auth status when the app loads
  setTimeout(() => {
    useAuthStore.getState().checkAuth();
  }, 100);
}

export default useAuthStore;