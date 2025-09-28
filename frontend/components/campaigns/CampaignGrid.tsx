import React from 'react'
import { CampaignCard, Campaign } from './CampaignCard'

export function CampaignGrid() {
  const campaigns: Campaign[] = [
    {
      id: 1,
      title: 'Clean Water Initiative for Rural Villages',
      goal: 15000,
      raised: 6200,
      image: 'https://source.unsplash.com/random/800x600?water,community',
      category: 'Health',
      owner: 'GreenHope Org',
      supporters: 128
    },
    {
      id: 2,
      title: 'School Supplies for Underprivileged Kids',
      goal: 8000,
      raised: 5100,
      image: 'https://source.unsplash.com/random/800x600?school,children',
      category: 'Education',
      owner: 'BrightStart',
      supporters: 94
    },
    {
      id: 3,
      title: 'Emergency Relief Fund for Flood Victims',
      goal: 30000,
      raised: 14450,
      image: 'https://source.unsplash.com/random/800x600?flood,relief',
      category: 'Relief',
      owner: 'ReliefNow',
      supporters: 310
    },
    {
      id: 4,
      title: 'Community Urban Garden Expansion',
      goal: 12000,
      raised: 8450,
      image: 'https://source.unsplash.com/random/800x600?garden,community',
      category: 'Environment',
      owner: 'CityRoots',
      supporters: 203
    },
    {
      id: 5,
      title: 'Support Mental Health Outreach Program',
      goal: 20000,
      raised: 4000,
      image: 'https://source.unsplash.com/random/800x600?mentalhealth,care',
      category: 'Wellness',
      owner: 'MindCare',
      supporters: 57
    },
    {
      id: 6,
      title: 'Laptop Access for Remote Learners',
      goal: 10000,
      raised: 9950,
      image: 'https://source.unsplash.com/random/800x600?laptop,study',
      category: 'Technology',
      owner: 'FutureLearn',
      supporters: 181
    }
  ]

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-semibold text-gray-900">Active Campaigns</h2>
        <a
          href="/campaigns/new"
          className="inline-flex items-center text-sm font-medium text-primary-600 hover:text-primary-700"
        >
          Start a Campaign
        </a>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {campaigns.length === 0 && (
          <div className="col-span-full text-center text-gray-500 text-sm py-10 border rounded-md bg-white">
            No campaigns yet. Be the first to start one!
          </div>
        )}
        {campaigns.map(c => (
          <CampaignCard key={c.id} campaign={c} />
        ))}
      </div>
    </div>
  )
}

