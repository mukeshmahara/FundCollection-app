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
  setAuth: (data: { token: string; user: AuthState['user'] }) => void
  clearAuth: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      setAuth: ({ token, user }) => set({ token, user }),
      clearAuth: () => set({ token: null, user: null })
    }),
    {
      name: 'auth-store'
    }
  )
)
