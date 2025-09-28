export function Stats() {
  const stats = [
    { label: 'Total Raised', value: '$0' },
    { label: 'Active Campaigns', value: '0' },
    { label: 'Donors', value: '0' },
  ]
  return (
    <section className="py-12 border-b bg-white">
      <div className="max-w-5xl mx-auto px-4 grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
        {stats.map(s => (
          <div key={s.label} className="space-y-2">
            <div className="text-3xl font-bold text-gray-900">{s.value}</div>
            <div className="text-sm uppercase tracking-wide text-gray-500">{s.label}</div>
          </div>
        ))}
      </div>
    </section>
  )
}
