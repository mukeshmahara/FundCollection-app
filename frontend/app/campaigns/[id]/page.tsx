"use client"

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { useAuthStore } from '@/lib/store/auth'
import { Button } from '@/components/ui/button'

export default function CampaignShowPage() {
  const params = useParams() as { id?: string }
  const id = params?.id
  const router = useRouter()
  const token = useAuthStore((s) => s.token)
  const user = useAuthStore((s) => s.user)

  const [campaign, setCampaign] = useState<any | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [amount, setAmount] = useState<string>('')
  const [anonymous, setAnonymous] = useState(false)
  const [donating, setDonating] = useState(false)
  const [successMessage, setSuccessMessage] = useState<string | null>(null)

  useEffect(() => {
    if (!user) router.push('/login')
  }, [user, router])

  useEffect(() => {
    if (!id) return
    fetchCampaign()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id])

  async function fetchCampaign() {
    setLoading(true)
    setError(null)
    try {
      const res = await fetch(`/api/v1/campaigns/${id}`)
      if (!res.ok) {
        const body = await res.json().catch(() => null)
        setError(body?.status?.message || 'Failed to load campaign')
        return
      }
      const data = await res.json()
      // API returns data wrapped or raw depending on backend serializers
      const c = data?.data || data
      setCampaign(c)
    } catch (err: any) {
      setError(err?.message || 'Network error')
    } finally {
      setLoading(false)
    }
  }

  async function handleDonate(e: React.FormEvent) {
    e.preventDefault()
    if (!id || !amount) return
    setDonating(true)
    setError(null)
    setSuccessMessage(null)
    try {
      const res = await fetch(`/api/v1/campaigns/${id}/donate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {})
        },
        body: JSON.stringify({ donation: { amount: parseFloat(amount), anonymous } })
      })
      if (!res.ok) {
        const body = await res.json().catch(() => null)
        setError(body?.status?.message || 'Failed to donate')
        return
      }
      const data = await res.json()
      setSuccessMessage('Donation successful — thank you!')
      setAmount('')
      setAnonymous(false)
      // refresh campaign details (amount raised etc)
      fetchCampaign()
    } catch (err: any) {
      setError(err?.message || 'Network error')
    } finally {
      setDonating(false)
    }
  }

  if (!id) return <div className="max-w-md mx-auto p-6">Invalid campaign</div>

  return (
    <div className="max-w-2xl mx-auto bg-white p-6 rounded shadow">
      {loading && <div className="mb-4">Loading...</div>}
      {error && <div className="mb-4 text-sm text-red-600">{error}</div>}
      {campaign && (
        <>
          <h1 className="text-2xl font-semibold mb-2">{campaign.title}</h1>
          {campaign.image_url && <img src={campaign.image_url} alt={campaign.title} className="mb-4 w-full h-48 object-cover rounded" />}
          <p className="text-gray-700 mb-4">{campaign.description}</p>

          <div className="mb-4 grid grid-cols-3 gap-4">
            <div>
              <p className="text-sm text-gray-600">Goal</p>
              <div className="font-medium">{campaign.goal_amount}</div>
            </div>
            <div>
              <p className="text-sm text-gray-600">Raised</p>
              <div className="font-medium">{campaign.total_raised}</div>
            </div>
            <div>
              <p className="text-sm text-gray-600">Donations</p>
              <div className="font-medium">{campaign.donation_count}</div>
            </div>
          </div>

          <form onSubmit={handleDonate} className="mb-4">
            <label className="block mb-2">
              <span className="text-sm text-gray-700">Amount</span>
              <input
                type="number"
                min="1"
                step="0.01"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                required
                className="mt-1 block w-full border rounded px-3 py-2"
                placeholder="10.00"
              />
            </label>

            <label className="flex items-center gap-2 mb-4">
              <input type="checkbox" checked={anonymous} onChange={(e) => setAnonymous(e.target.checked)} />
              <span className="text-sm text-gray-700">Donate anonymously</span>
            </label>

            <div>
              <Button type="submit" className="w-full py-3" disabled={donating}>{donating ? 'Donating...' : 'Donate'}</Button>
            </div>
          </form>

          {successMessage && <div className="mb-4 text-sm text-green-600">{successMessage}</div>}

        </>
      )}
    </div>
  )
}
