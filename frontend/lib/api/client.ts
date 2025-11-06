import axios from 'axios'
import { useAuthStore } from '@/lib/store/auth'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

// Create axios instance
export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  },
  withCredentials: true
})

// Add Authorization header from zustand store (works outside React using getState)
api.interceptors.request.use(
  (config) => {
    try {
      const token = useAuthStore.getState().token
      if (token) {
        // axios types are strict; use a small local object when needed
        if (!config.headers) {
          config.headers = { Authorization: `Bearer ${token}` } as any
        } else {
          ;(config.headers as any).Authorization = `Bearer ${token}`
        }
      }
    } catch (e) {
      // ignore
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor: on 401 clear local auth and optionally redirect to login
api.interceptors.response.use(
  (resp) => resp,
  (error) => {
    const status = error?.response?.status
    if (status === 401) {
      try {
        const clearAuth = useAuthStore.getState().clearAuth
        clearAuth && clearAuth()
        // avoid throwing during SSR
        if (typeof window !== 'undefined') window.location.href = '/login'
      } catch (e) {
        // ignore
      }
    }
    return Promise.reject(error)
  }
)

export default api
