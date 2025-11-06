import api from './client'

export async function getUser(id: string | number) {
  const res = await api.get(`/api/v1/users/${id}`)
  return res.data
}

export async function updateUser(id: string | number, payload: any) {
  const res = await api.put(`/api/v1/users/${id}`, payload)
  return res.data
}

export async function logout() {
  const res = await api.delete('/api/v1/logout')
  return res.data
}

export default {
  getUser,
  updateUser,
  logout
}
