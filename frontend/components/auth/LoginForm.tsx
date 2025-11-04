'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/lib/store/auth'
import { Button } from '@/components/ui/button'

export function LoginForm() {
  const router = useRouter()
  const setAuth = useAuthStore((s) => s.setAuth)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [remember, setRemember] = useState(true)
  const [phoneMode, setPhoneMode] = useState(false)
  const [phone, setPhone] = useState('')
  const [otpSent, setOtpSent] = useState(false)
  const [otpCode, setOtpCode] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)
    setLoading(true)

    try {
      const res = await fetch('/api/v1/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user: { email, password } })
      })

      if (!res.ok) {
        const body = await res.json().catch(() => null)
        setError(body?.status?.message || 'Login failed')
        setLoading(false)
        return
      }

      const data = await res.json()
      const token = data?.data?.token
      const user = data?.data?.user
      if (token && user) {
        setAuth({ token, user, remember })
        // navigate back to home or to a saved redirect
        router.push('/')
      } else {
        setError('Invalid server response')
      }
    } catch (err: any) {
      setError(err?.message || 'Network error')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="max-w-md mx-auto bg-white p-6 rounded shadow">
      <h2 className="text-2xl font-semibold mb-4">Login to Collect</h2>

      {/* Segmented control for Phone / Email */}
      <div className="flex gap-2 mb-4">
        <button
          type="button"
          onClick={() => { setPhoneMode(true); setOtpSent(false); setOtpCode('') }}
          className={`px-4 py-2 rounded-full text-sm ${phoneMode ? 'bg-primary-600 text-white' : 'bg-gray-100 text-gray-700'}`}>
          Phone Number
        </button>
        <button
          type="button"
          onClick={() => { setPhoneMode(false); setOtpSent(false); setOtpCode('') }}
          className={`px-4 py-2 rounded-full text-sm ${!phoneMode ? 'bg-primary-600 text-white' : 'bg-gray-100 text-gray-700'}`}>
          Email
        </button>
      </div>

      {error && <div className="mb-4 text-sm text-red-600">{error}</div>}

      <div className="mb-4">
        {phoneMode ? (
          // Phone flow
          !otpSent ? (
            <>
              <label className="block mb-4">
                <span className="text-sm text-gray-700">Phone Number</span>
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+966 055 123 4567"
                  required
                  className="mt-1 block w-full border rounded px-3 py-3"
                />
              </label>

              <div className="mb-2">
                <Button className="w-full py-3" type="button" onClick={async () => {
                  setError(null)
                  setLoading(true)
                  try {
                    const res = await fetch('/api/v1/login_with_phone', {
                      method: 'POST',
                      headers: { 'Content-Type': 'application/json' },
                      body: JSON.stringify({ user: { phone_number: phone } })
                    })
                    if (!res.ok) {
                      const body = await res.json().catch(() => null)
                      setError(body?.status?.message || 'Failed to send OTP')
                      setLoading(false)
                      return
                    }
                    setOtpSent(true)
                  } catch (err: any) {
                    setError(err?.message || 'Network error')
                  } finally { setLoading(false) }
                }}>{loading ? 'Sending...' : 'Login'}</Button>
              </div>
            </>
          ) : (
            // OTP verification UI (4 boxes)
            <>
              <div className="mb-3">
                <p className="text-sm text-gray-600">Enter the 4 digit code sent to your phone</p>
              </div>
              <div className="flex gap-2 justify-center mb-4">
                {[0,1,2,3].map((i) => (
                  <input
                    key={i}
                    type="text"
                    inputMode="numeric"
                    maxLength={1}
                    value={otpCode[i] ?? ''}
                    onChange={(e) => {
                      const ch = e.target.value.replace(/[^0-9]/g, '').slice(0,1)
                      const arr = otpCode.split('').slice(0,4)
                      arr[i] = ch
                      const next = arr.join('').padEnd(4, '')
                      setOtpCode(next)
                      // try focus next input
                      const nextInput = (document.querySelectorAll('input[data-otp]')[i+1] as HTMLInputElement | undefined)
                      if (ch && nextInput) nextInput.focus()
                    }}
                    data-otp
                    className="w-12 h-12 text-center border rounded-lg text-lg"
                  />
                ))}
              </div>

              <div>
                <Button className="w-full py-3" type="button" onClick={async () => {
                  setError(null)
                  setLoading(true)
                  try {
                    const res = await fetch('/api/v1/verify_otp', {
                      method: 'POST',
                      headers: { 'Content-Type': 'application/json' },
                      body: JSON.stringify({ user: { phone_number: phone, otp_code: otpCode } })
                    })
                    if (!res.ok) {
                      const body = await res.json().catch(() => null)
                      setError(body?.status?.message || 'Failed to verify OTP')
                      setLoading(false)
                      return
                    }
                    const data = await res.json()
                    const token = data?.data?.token
                    const user = data?.data?.user
                    if (token && user) {
                      setAuth({ token, user, remember })
                      router.push('/')
                    } else {
                      setError('Invalid server response')
                    }
                  } catch (err: any) {
                    setError(err?.message || 'Network error')
                  } finally { setLoading(false) }
                }}>{loading ? 'Verifying...' : 'Verify & Login'}</Button>
              </div>
            </>
          )
        ) : (
          // Email flow
          <>
            <label className="block mb-2">
              <span className="text-sm text-gray-700">Email</span>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="mt-1 block w-full border rounded px-3 py-3"
              />
            </label>

            <label className="block mb-2">
              <span className="text-sm text-gray-700">Password</span>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="mt-1 block w-full border rounded px-3 py-3"
              />
            </label>

            <label className="flex items-center gap-2 mb-4">
              <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} />
              <span className="text-sm text-gray-700">Remember me</span>
            </label>

            <div>
              <Button type="submit" className="w-full py-3" disabled={loading}>{loading ? 'Logging in...' : 'Login'}</Button>
            </div>

            <div className="mt-4 text-right">
              <a href="/forgot-password" className="text-sm text-primary-600 hover:underline">Forgot password?</a>
            </div>
          </>
        )}
      </div>
    </form>
  )
}
