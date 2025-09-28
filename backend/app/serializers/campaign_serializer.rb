class CampaignSerializer
  include JSONAPI::Serializer
  
  attributes :id, :title, :description, :goal_amount, :deadline, :status, :created_at, :updated_at

  attribute :total_raised do |campaign|
    campaign.total_raised
  end

  attribute :percentage_raised do |campaign|
    campaign.percentage_raised
  end

  attribute :days_remaining do |campaign|
    campaign.days_remaining
  end

  attribute :donation_count do |campaign|
    campaign.donation_count
  end

  attribute :is_funded do |campaign|
    campaign.is_funded?
  end

  attribute :is_expired do |campaign|
    campaign.is_expired?
  end

  attribute :can_receive_donations do |campaign|
    campaign.can_receive_donations?
  end

  attribute :image_url do |campaign|
    if campaign.image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(campaign.image, only_path: true)
    end
  end

  belongs_to :creator, serializer: UserSerializer
  has_many :donations, serializer: DonationSerializer
end
