class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json
  # Skip auth for create (login) and destroy (logout) to avoid Devise session access in API mode.
  skip_before_action :authenticate_user!, only: [ :create, :destroy ]

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
    # Stateless logout: decode token (if present) and clear refresh tokens for that user.
    token = request.headers["Authorization"]&.split(" ")&.last
    if token.present?
      begin
        jwt_secret = Rails.application.credentials.devise_jwt_secret_key || Rails.application.secret_key_base
        payload = JWT.decode(token, jwt_secret).first
        if (user_id = payload["sub"])
          if (user = User.find_by(id: user_id)) && user.respond_to?(:refresh_tokens)
            user.refresh_tokens.delete_all
          end
        end
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        # Ignore; still return generic success (idempotent logout)
      end
    end
    render json: { status: 200, message: "Logged out successfully." }, status: :ok
  end
  private
end
