"use client"

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/lib/store/auth'
import { Button } from '@/components/ui/button'

export default function ProfilePage() {
  const router = useRouter()
  const token = useAuthStore((s) => s.token)
  const user = useAuthStore((s) => s.user)
  const setAuth = useAuthStore((s) => s.setAuth)
  const clearAuth = useAuthStore((s) => s.clearAuth)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!user) {
      // Not logged in -> redirect to login
      router.push('/login')
    }
  }, [user, router])

  async function handleLogout() {
    setLoading(true)
    setError(null)
    try {
      // Best-effort: call backend logout to revoke refresh token
      await fetch('/api/v1/logout', {
        method: 'DELETE',
        headers: token ? { Authorization: `Bearer ${token}` } : undefined
      }).catch(() => null)
    } finally {
      clearAuth()
      setLoading(false)
      router.push('/login')
    }
  }

  async function refreshProfile() {
    if (!user || !token) return
    setLoading(true)
    setError(null)
    try {
      const res = await fetch(`/api/v1/users/${user.id}`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      if (!res.ok) {
        const body = await res.json().catch(() => null)
        setError(body?.status?.message || 'Failed to fetch profile')
        return
      }
      const data = await res.json()
      const freshUser = data?.data || data
      // preserve token and persist (default remember=true)
      setAuth({ token: token, user: freshUser, remember: true })
    } catch (err: any) {
      setError(err?.message || 'Network error')
    } finally {
      setLoading(false)
    }
  }

  if (!user) return null

  return (
    <div className="max-w-md mx-auto bg-white p-6 rounded shadow">
      <h1 className="text-2xl font-semibold mb-4">Profile</h1>

      {error && <div className="mb-4 text-sm text-red-600">{error}</div>}

      <div className="mb-4">
        <p className="text-sm text-gray-600">Name</p>
        <div className="font-medium">{user.first_name ?? ''} {user.last_name ?? ''}</div>
      </div>

      <div className="mb-4">
        <p className="text-sm text-gray-600">Email</p>
        <div className="font-medium">{user.email}</div>
      </div>

      <div className="mb-4">
        <p className="text-sm text-gray-600">User ID</p>
        <div className="font-mono text-sm">{user.id}</div>
      </div>

      <div className="flex gap-2">
        <Button variant="secondary" onClick={refreshProfile} disabled={loading}>{loading ? 'Please wait...' : 'Refresh'}</Button>
        <Button className="ml-auto" onClick={handleLogout} disabled={loading}>{loading ? 'Logging out...' : 'Logout'}</Button>
      </div>
    </div>
  )
}
