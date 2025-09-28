import React from 'react'

export interface Campaign {
  id: number
  title: string
  goal: number
  raised: number
  image?: string
  category?: string
  owner?: string
  supporters?: number
}

export function CampaignCard({ campaign }: { campaign: Campaign }) {
  const pct = campaign.goal > 0 ? Math.min(100, Math.round((campaign.raised / campaign.goal) * 100)) : 0
  return (
    <div className="border rounded-lg overflow-hidden bg-white shadow-sm hover:shadow-md transition-shadow flex flex-col">
      {campaign.image ? (
        <div className="h-40 w-full bg-gray-100 overflow-hidden">
          <img
            src={campaign.image}
            alt={campaign.title}
            className="w-full h-full object-cover"
            loading="lazy"
          />
        </div>
      ) : (
        <div className="h-40 w-full bg-gradient-to-br from-primary-100 to-primary-200 flex items-center justify-center text-primary-700 text-sm font-medium">
          No Image
        </div>
      )}
      <div className="p-4 flex flex-col flex-1">
        {campaign.category && (
          <span className="inline-block text-[11px] font-medium uppercase tracking-wide text-primary-700 bg-primary-50 px-2 py-1 rounded mb-2">
            {campaign.category}
          </span>
        )}
        <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2" title={campaign.title}>{campaign.title}</h3>
        <div className="mb-3">
          <div className="h-2 w-full bg-gray-200 rounded">
            <div
              className="h-2 bg-primary-500 rounded"
              style={{ width: `${pct}%` }}
            />
          </div>
          <div className="mt-2 flex justify-between text-xs text-gray-600">
            <span>${campaign.raised.toLocaleString()} raised</span>
            <span>{pct}%</span>
          </div>
        </div>
        <div className="mt-auto text-xs text-gray-500 space-y-1">
          <div>Goal: ${campaign.goal.toLocaleString()}</div>
          {campaign.supporters !== undefined && (
            <div>{campaign.supporters} supporter{campaign.supporters === 1 ? '' : 's'}</div>
          )}
          {campaign.owner && <div>By {campaign.owner}</div>}
        </div>
        <a
          href={`/campaigns/${campaign.id}`}
          className="mt-4 inline-flex items-center justify-center text-sm font-medium text-primary-600 hover:text-primary-700"
        >
          View Details →
        </a>
      </div>
    </div>
  )
}
