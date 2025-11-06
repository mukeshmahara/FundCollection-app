import axios, { AxiosRequestConfig, AxiosError } from 'axios'
import { useAuthStore } from '@/lib/store/auth'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  },
  withCredentials: true
})

// Single-flight refresh state
let isRefreshing = false
let refreshPromise: Promise<string | null> | null = null
const refreshSubscribers: Array<(token: string | null) => void> = []

function subscribeTokenRefresh(cb: (token: string | null) => void) {
  refreshSubscribers.push(cb)
}

function onRefreshed(token: string | null) {
  refreshSubscribers.forEach((cb) => cb(token))
  refreshSubscribers.length = 0
}

async function doRefresh(): Promise<string | null> {
  if (isRefreshing && refreshPromise) return refreshPromise
  isRefreshing = true
  refreshPromise = (async () => {
    try {
      // read refresh token from store or storage
      let refreshToken = useAuthStore.getState().refreshToken
      if (!refreshToken && typeof window !== 'undefined') {
        try {
          const sess = sessionStorage.getItem('auth-store')
          const local = localStorage.getItem('auth-store')
          const raw = sess || local
          if (raw) {
            const parsed = JSON.parse(raw)
            refreshToken = parsed?.refreshToken || parsed?.refresh_token
          }
        } catch (e) {}
      }
      if (!refreshToken) return null

      const resp = await api.post('/api/v1/tokens/refresh', { refresh_token: refreshToken })
      const data = resp?.data?.data || resp?.data
      const newToken = data?.token || data?.access_token
      const newRefresh = data?.refresh_token || data?.refreshToken || null

      if (newToken) {
        // preserve current user
        const user = useAuthStore.getState().user
        const remember = !!localStorage.getItem('auth-store')
        useAuthStore.getState().setAuth({ token: newToken, refreshToken: newRefresh, user: user as any, remember })
        return newToken
      }
      return null
    } catch (err) {
      try { useAuthStore.getState().clearAuth() } catch (e) {}
      return null
    } finally {
      isRefreshing = false
      refreshPromise = null
    }
  })()
  return refreshPromise
}

// Add Authorization header from zustand store (works outside React using getState)
api.interceptors.request.use(
  (config: any) => {
    try {
      let token = useAuthStore.getState().token
      // If the store hasn't rehydrated yet, fall back to reading storage directly
      if (!token && typeof window !== 'undefined') {
        try {
          const sess = sessionStorage.getItem('auth-store')
          const local = localStorage.getItem('auth-store')
          const raw = sess || local
          if (raw) {
            const parsed = JSON.parse(raw)
            token = parsed?.token
          }
        } catch (e) {
          // ignore parse errors
        }
      }
      if (token) {
        if (!config.headers) config.headers = {} as any
        ;(config.headers as any).Authorization = `Bearer ${token}`
      }
    } catch (e) {
      // ignore
    }
    return config
  },
  (error: any) => Promise.reject(error)
)

// Response interceptor: on 401 try refresh once and retry original request
api.interceptors.response.use(
  (resp: any) => resp,
  async (error: any) => {
    const status = error?.response?.status
    const originalRequest = error?.config as any
    if (status === 401 && originalRequest && !originalRequest._retry) {
      originalRequest._retry = true
      try {
        const newToken = await doRefresh()
        if (newToken) {
          // retry the original request with new token
          if (!originalRequest.headers) originalRequest.headers = {}
          originalRequest.headers.Authorization = `Bearer ${newToken}`
          return api(originalRequest)
        }
      } catch (e) {
        // fallthrough to clearing auth
      }
      // refresh failed -> clear auth and redirect to login
      try {
        const clearAuth = useAuthStore.getState().clearAuth
        clearAuth && clearAuth()
        if (typeof window !== 'undefined') window.location.href = '/login'
      } catch (e) {}
    }
    return Promise.reject(error)
  }
)

export default api
