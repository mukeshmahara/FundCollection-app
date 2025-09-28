class UserSerializer
  include JSONAPI::Serializer
  
  attributes :id, :email, :first_name, :last_name, :role, :created_at

  attribute :full_name do |user|
    user.full_name
  end

  attribute :total_donated do |user|
    user.total_donated
  end

  attribute :avatar_url do |user|
    if user.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(user.avatar, only_path: true)
    end
  end
end
