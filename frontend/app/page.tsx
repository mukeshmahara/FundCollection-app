import { CampaignGrid } from '../components/campaigns/CampaignGrid'
import { Hero } from '../components/home/Hero'
import { Stats } from '../components/home/Stats'

export default function HomePage() {
  return (
    <div>
      <Hero />
      <Stats />
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Featured Campaigns
            </h2>
            <p className="text-lg text-gray-600">
              Support causes that matter to you
            </p>
          </div>
          <CampaignGrid />
        </div>
      </section>
    </div>
  )
}
