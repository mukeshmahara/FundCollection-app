import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export interface AuthState {
  token: string | null
  user: {
    id: number
    email: string
    first_name?: string
    last_name?: string
    role?: string
  } | null
  // remember === true -> persist in localStorage, false -> persist in sessionStorage
  setAuth: (data: { token: string; user: AuthState['user']; remember?: boolean }) => void
  clearAuth: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      setAuth: ({ token, user, remember = true }) => {
        // Save to zustand state (persist middleware will store to localStorage by default)
        set({ token, user })

        const payload = JSON.stringify({ token, user })
        try {
          if (remember) {
            // store in localStorage and remove any session entry
            localStorage.setItem('auth-store', payload)
            sessionStorage.removeItem('auth-store')
          } else {
            // store in sessionStorage and remove any local persistent entry
            sessionStorage.setItem('auth-store', payload)
            localStorage.removeItem('auth-store')
          }
        } catch (e) {
          // ignore storage errors
        }
      },
      clearAuth: () => {
        set({ token: null, user: null })
        try {
          localStorage.removeItem('auth-store')
          sessionStorage.removeItem('auth-temp')
        } catch (e) {}
      }
    }),
    {
      name: 'auth-store',
      // custom storage that reads sessionStorage first (for non-remembered sessions)
      getStorage: () => {
        const storage = {
          getItem: (name: string) => {
            try {
              const sess = sessionStorage.getItem('auth-store')
              if (sess) return sess
              return localStorage.getItem('auth-store')
            } catch (e) {
              return null
            }
          },
          setItem: (name: string, value: string) => {
            try {
              // If a session value exists, prefer writing to sessionStorage so session-only logins survive refresh.
              const sessExists = !!sessionStorage.getItem('auth-store')
              if (sessExists) {
                sessionStorage.setItem('auth-store', value)
              } else {
                localStorage.setItem('auth-store', value)
              }
            } catch (e) {}
          },
          removeItem: (name: string) => {
            try {
              localStorage.removeItem('auth-store')
              sessionStorage.removeItem('auth-store')
            } catch (e) {}
          }
        }
        return storage as unknown as Storage
      }
    }
  )
)
