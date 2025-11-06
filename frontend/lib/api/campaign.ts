import api from './client'

export async function getCampaign(id: string | number) {
  const res = await api.get(`/api/v1/campaigns/${id}`)
  return res.data
}

export async function listCampaigns(params?: Record<string, any>) {
  const res = await api.get('/api/v1/campaigns', { params })
  return res.data
}

export async function donate(campaignId: string | number, donation: { amount: number; anonymous?: boolean }) {
  const res = await api.post(`/api/v1/campaigns/${campaignId}/donate`, { donation })
  return res.data
}

export default {
  getCampaign,
  listCampaigns,
  donate
}
