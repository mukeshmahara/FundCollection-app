export function CampaignGrid() {
  // Placeholder list - integrate API later
  const campaigns: { id: number; title: string; goal: number; raised: number }[] = []
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      {campaigns.length === 0 && (
        <div className="col-span-full text-center text-gray-500 text-sm py-8 border rounded-md bg-white">
          No campaigns yet. Be the first to start one!
        </div>
      )}
      {campaigns.map(c => (
        <div key={c.id} className="border rounded-lg p-4 bg-white shadow-sm hover:shadow transition-shadow">
          <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2">{c.title}</h3>
          <div className="text-sm text-gray-600 mb-4">Raised ${c.raised} of ${c.goal}</div>
          <a href={`/campaigns/${c.id}`} className="text-primary-600 text-sm font-medium hover:underline">View Details</a>
        </div>
      ))}
    </div>
  )
}
