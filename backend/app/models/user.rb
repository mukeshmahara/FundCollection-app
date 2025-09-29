class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Enums
  enum :role, { donor: 0, admin: 1 }

  # Associations
  has_many :donations, dependent: :destroy
  has_many :campaigns, through: :donations
  has_many :created_campaigns, class_name: "Campaign", foreign_key: "creator_id", dependent: :destroy
  has_one_attached :avatar
  has_many :refresh_tokens, dependent: :delete_all

  # Validations
  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  # Scopes
  scope :donors, -> { where(role: :donor) }
  scope :admins, -> { where(role: :admin) }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def total_donated
    donations.successful.sum(:amount)
  end

  def admin?
    role == "admin"
  end

  def donor?
    role == "donor"
  end
end
