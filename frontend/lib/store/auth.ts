import { create } from 'zustand'
import { persist } from 'zustand/middleware'

// Read any persisted auth synchronously (used to seed the initial state)
function readPersistedAuth() {
  if (typeof window === 'undefined') return null
  try {
    const sess = sessionStorage.getItem('auth-store')
    const local = localStorage.getItem('auth-store')
    const raw = sess || local
    if (!raw) return null
    return JSON.parse(raw)
  } catch (e) {
    return null
  }
}

const _persisted = readPersistedAuth()

export interface AuthState {
  token: string | null
  refreshToken?: string | null
  user: {
    id: number
    email: string
    first_name?: string
    last_name?: string
    role?: string
  } | null
  // remember === true -> persist in localStorage, false -> persist in sessionStorage
  setAuth: (data: { token: string; refreshToken?: string | null; user: AuthState['user']; remember?: boolean }) => void
  clearAuth: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
  token: _persisted?.token ?? null,
  refreshToken: _persisted?.refreshToken ?? _persisted?.refresh_token ?? null,
  user: _persisted?.user ?? null,
      setAuth: ({ token, refreshToken, user, remember = true }) => {
        // preserve existing refreshToken if caller didn't provide one
        const existing = (get as any)().refreshToken
        const finalRefresh = typeof refreshToken === 'undefined' ? existing ?? null : refreshToken
        // Save to zustand state (persist middleware will store to localStorage by default)
        set({ token, refreshToken: finalRefresh, user })

        const payload = JSON.stringify({ token, refreshToken: finalRefresh, user })
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
          sessionStorage.removeItem('auth-store')
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
