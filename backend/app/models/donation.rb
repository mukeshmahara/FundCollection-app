class Donation < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :campaign
  has_one :payment_transaction, class_name: 'Transaction', dependent: :destroy

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validate :campaign_can_receive_donations

  # Enums
  enum :status, { pending: 0, successful: 1, failed: 2, refunded: 3 }

  # Scopes
  scope :successful, -> { where(status: :successful) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_amount, ->(order = :desc) { order(amount: order) }

  # Callbacks
  after_update :check_campaign_completion, if: :saved_change_to_status?

  # Instance methods
  def donor_name
    anonymous? ? 'Anonymous' : user.full_name
  end

  def display_amount
    "$#{amount.to_f}"
  end

  def processing?
    pending?
  end

  private

  def campaign_can_receive_donations
    return unless campaign

    unless campaign.can_receive_donations?
      errors.add(:campaign, 'cannot receive donations (either inactive or expired)')
    end
  end

  def check_campaign_completion
    return unless successful?

    campaign.reload
    if campaign.is_funded? && campaign.active?
      campaign.update(status: :completed)
    end
  end
end
