class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :authenticate_user!, only: [ :create ]

  def create
    # Attempt Devise authentication
    self.resource = warden.authenticate(auth_options)
    user = self.resource

    unless user
      # Manual fallback (ensures we return consistent JSON instead of Devise HTML-ish message)
      email = params.dig(:user, :email)&.downcase
      password = params.dig(:user, :password)
      if email.present? && password.present?
        candidate = User.find_by(email: email)
        user = candidate if candidate&.valid_password?(password)
      end
    end

    if user
      # Directly issue JWT without establishing a Warden session
      token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, resource_name, nil)
      render json: {
        status: { code: 200, message: "Logged in successfully." },
        data: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes],
          token: token
        }
      }, status: :ok
    else
      render json: { status: { code: 401, message: "Invalid email or password" } }, status: :unauthorized
    end
  end

  def destroy
    current_user.refresh_tokens.delete_all
    super
  end

  private

  def respond_to_on_destroy
    token = request.headers["Authorization"]&.split(" ")&.last
    user = nil
    if token.present?
      begin
        jwt_payload = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key || Rails.application.secret_key_base).first
        user = User.find_by(id: jwt_payload["sub"])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        user = nil
      end
    end

    if user
      render json: { status: 200, message: "Logged out successfully." }, status: :ok
    else
      render json: { status: 401, message: "Couldn't find an active session." }, status: :unauthorized
    end
  end
end
