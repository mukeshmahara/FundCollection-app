class Otp < ApplicationRecord
  validates :phone_number, presence: true
  validates :code, presence: true
  validates :expires_at, presence: true

  def expired?
    Time.current > expires_at
  end
end
