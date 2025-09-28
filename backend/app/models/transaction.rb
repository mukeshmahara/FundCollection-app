class Transaction < ApplicationRecord
  # Associations
  belongs_to :donation

  # Validations
  validates :stripe_payment_intent_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  # Enums
  enum :status, { 
    requires_payment_method: 0,
    requires_confirmation: 1, 
    requires_action: 2,
    processing: 3,
    succeeded: 4,
    requires_capture: 5,
    canceled: 6
  }

  # Scopes
  scope :successful, -> { where(status: :succeeded) }
  scope :failed, -> { where(status: [:canceled]) }

  # Instance methods
  def successful?
    succeeded?
  end

  def failed?
    canceled?
  end

  def stripe_url
    "https://dashboard.stripe.com/payments/#{stripe_payment_intent_id}" if stripe_payment_intent_id
  end
end
