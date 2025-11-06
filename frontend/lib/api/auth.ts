import api from './client'

type LoginParams = { email: string; password: string }
type PhoneParams = { phone_number: string }

export async function login(email: string, password: string) {
  const res = await api.post('/api/v1/login', { user: { email, password } })
  return res.data
}

export async function signup(payload: any) {
  // payload should follow backend contract: { user: { ... } }
  const res = await api.post('/api/v1/users', payload)
  return res.data
}

export async function sendLoginOtp(phone: string) {
  const res = await api.post('/api/v1/login_with_phone', { user: { phone_number: phone } })
  return res.data
}

export async function verifyOtp(phone: string, otp_code: string) {
  const res = await api.post('/api/v1/verify_otp', { user: { phone_number: phone, otp_code } })
  return res.data
}

export async function forgotPassword(email: string) {
  const res = await api.post('/api/v1/passwords', { user: { email } })
  return res.data
}

export async function resetPassword(payload: any) {
  // payload likely { user: { reset_token, password, password_confirmation } }
  const res = await api.post('/api/v1/passwords/reset', payload).catch(async (err) => {
    // some backends use PUT /api/v1/passwords
    if (err?.response?.status === 404) return api.put('/api/v1/passwords', payload).then((r) => r.data)
    throw err
  })
  return res.data
}

export default {
  login,
  signup,
  sendLoginOtp,
  verifyOtp,
  forgotPassword,
  resetPassword
}
