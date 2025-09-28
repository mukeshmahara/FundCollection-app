class Campaign < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :donations, dependent: :destroy
  has_many :donors, through: :donations, source: :user
  has_one_attached :image
  has_rich_text :description

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20 }
  validates :goal_amount, presence: true, numericality: { greater_than: 0 }
  validates :deadline, presence: true
  validates :status, presence: true
  validate :deadline_cannot_be_in_the_past

  # Enums
  enum :status, { draft: 0, active: 1, completed: 2, cancelled: 3 }

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :trending, -> { joins(:donations).group('campaigns.id').order('SUM(donations.amount) DESC') }
  scope :recent, -> { order(created_at: :desc) }
  scope :ending_soon, -> { where('deadline > ? AND deadline <= ?', Time.current, 7.days.from_now) }

  # Instance methods
  def total_raised
    donations.successful.sum(:amount)
  end

  def percentage_raised
    return 0 if goal_amount.zero?
    ((total_raised.to_f / goal_amount) * 100).round(2)
  end

  def days_remaining
    return 0 if deadline.past?
    (deadline.to_date - Date.current).to_i
  end

  def is_funded?
    total_raised >= goal_amount
  end

  def is_expired?
    deadline.past?
  end

  def donation_count
    donations.successful.count
  end

  def recent_donations(limit = 5)
    donations.successful.includes(:user).order(created_at: :desc).limit(limit)
  end

  def can_receive_donations?
    active? && !is_expired?
  end

  private

  def deadline_cannot_be_in_the_past
    return unless deadline.present? && deadline < Time.current

    errors.add(:deadline, "can't be in the past")
  end
end
