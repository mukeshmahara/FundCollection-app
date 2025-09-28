export function Hero() {
  return (
    <section className="bg-gradient-to-br from-primary-50 to-white py-20 border-b">
      <div className="max-w-5xl mx-auto px-4 text-center">
        <h1 className="text-4xl md:text-5xl font-bold tracking-tight text-gray-900 mb-6">
          Empower Change Through Crowdfunding
        </h1>
        <p className="text-lg text-gray-600 mb-8 max-w-2xl mx-auto">
          Start a campaign, donate to meaningful causes, and track the impact of collective generosity.
        </p>
        <div className="flex items-center justify-center gap-4">
          <a href="/campaigns" className="inline-flex items-center rounded-md bg-primary-600 px-6 py-3 text-white font-medium shadow hover:bg-primary-700 transition-colors">
            Explore Campaigns
          </a>
          <a href="/start" className="inline-flex items-center rounded-md border border-primary-600 px-6 py-3 text-primary-700 font-medium hover:bg-primary-50 transition-colors">
            Start a Campaign
          </a>
        </div>
      </div>
    </section>
  )
}
