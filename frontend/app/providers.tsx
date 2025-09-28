"use client"

import { QueryClient, QueryClientProvider } from 'react-query'
import { useState, useEffect } from 'react'
import { ToastContainer } from 'react-toastify'
import 'react-toastify/dist/ReactToastify.css'
import { Navbar } from '@/components/layout/Navbar'
import { useAuthStore, AuthState } from '@/lib/store/auth'

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient())
  const token = useAuthStore((s: AuthState) => s.token)

  // Example side effect placeholder (e.g., refresh user, warm cache)
  useEffect(() => {
    if (token) {
      // Could trigger a user refetch here
    }
  }, [token])

  return (
    <QueryClientProvider client={queryClient}>
      <Navbar />
      <main className="min-h-screen bg-gray-50">
        {children}
      </main>
      <ToastContainer
        position="top-right"
        autoClose={5000}
        hideProgressBar={false}
        newestOnTop
        closeOnClick
        rtl={false}
        pauseOnFocusLoss
        draggable
        pauseOnHover
      />
    </QueryClientProvider>
  )
}
