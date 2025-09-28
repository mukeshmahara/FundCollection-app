class DonationSerializer
  include JSONAPI::Serializer
  
  attributes :id, :amount, :anonymous, :status, :created_at, :updated_at

  attribute :donor_name do |donation|
    donation.donor_name
  end

  attribute :display_amount do |donation|
    donation.display_amount
  end

  belongs_to :user, serializer: UserSerializer
  belongs_to :campaign, serializer: CampaignSerializer
  has_one :transaction, serializer: TransactionSerializer
end
