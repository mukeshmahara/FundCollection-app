'use client'

import { useState } from 'react'
import * as authApi from '@/lib/api/auth'

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('')
  const [status, setStatus] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setStatus(null)
    setLoading(true)
    try {
      await authApi.forgotPassword(email)
      setStatus('If your email is registered, you will receive reset instructions.')
    } catch (e: any) {
      setStatus(e?.message || 'Network error')
    } finally { setLoading(false) }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12">
      <div className="w-full max-w-md px-4">
        <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow">
          <h2 className="text-2xl font-semibold mb-4">Forgot Password</h2>
          {status && <div className="mb-4 text-sm text-gray-700">{status}</div>}
          <label className="block mb-4">
            <span className="text-sm text-gray-700">Email</span>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="mt-1 block w-full border rounded px-3 py-2"
            />
          </label>
          <div className="flex justify-end">
            <button className="btn" type="submit" disabled={loading}>{loading ? 'Sending...' : 'Send reset email'}</button>
          </div>
        </form>
      </div>
    </div>
  )
}
