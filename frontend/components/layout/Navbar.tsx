'use client'
import Link from 'next/link'
import { useAuthStore } from '@/lib/store/auth'
import { Button } from '@/components/ui/button'

export function Navbar() {
  const { user, clearAuth } = useAuthStore()
  return (
    <nav className="border-b bg-white/70 backdrop-blur-sm sticky top-0 z-40">
      <div className="max-w-6xl mx-auto flex items-center justify-between h-14 px-4">
        <Link href="/" className="font-semibold text-primary-700">FundCollection</Link>
        <div className="flex items-center gap-4">
          {user ? (
            <>
              <span className="text-sm text-gray-600">Hi, {user.first_name || user.email}</span>
              <Button variant="outline" size="sm" onClick={clearAuth}>Logout</Button>
            </>
          ) : (
            <>
              <Link href="/login" className="text-sm text-gray-600 hover:text-primary-600">Login</Link>
              <Link href="/signup" className="text-sm text-gray-600 hover:text-primary-600">Sign Up</Link>
            </>
          )}
        </div>
      </div>
    </nav>
  )
}
