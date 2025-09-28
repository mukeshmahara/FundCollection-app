class TransactionSerializer
  include JSONAPI::Serializer
  
  attributes :id, :stripe_payment_intent_id, :amount, :status, :created_at, :updated_at

  attribute :stripe_url do |transaction|
    transaction.stripe_url
  end

  attribute :successful do |transaction|
    transaction.successful?
  end

  attribute :failed do |transaction|
    transaction.failed?
  end

  belongs_to :donation, serializer: DonationSerializer
end
