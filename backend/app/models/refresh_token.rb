class RefreshToken < ApplicationRecord
  belongs_to :user
   before_create :set_token_and_expiry

  def set_token_and_expiry
    self.token = SecureRandom.hex(32)
    self.expires_at = 7.days.from_now
  end

  def expired?
    Time.current > expires_at
  end
end
