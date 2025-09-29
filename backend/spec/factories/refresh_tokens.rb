FactoryBot.define do
  factory :refresh_token do
    user { nil }
    token { "MyString" }
    expires_at { "2025-09-29 14:19:31" }
  end
end
