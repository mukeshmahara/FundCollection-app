
class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json
  # No authenticate_user! needed; login/logout are public/stateless endpoints.

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
      refresh = user.refresh_tokens.create!
      render json: {
        status: { code: 200, message: "Logged in successfully." },
        data: {
        user: UserSerializer.new(user).serializable_hash[:data][:attributes],
        token: token,
        refresh_token: refresh.token,
        refresh_expires_at: refresh.expires_at
        }
      }, status: :ok
    else
      render json: { status: { code: 401, message: "Invalid email or password" } }, status: :unauthorized
    end
  end

  def login_with_phone
    @request.env["devise.mapping"] = Devise.mappings[:user]
    phone = params.dig(:user, :phone_number)
    user = User.find_by(phone_number: phone)

    if user
      code = rand(100000..999999).to_s
      Otp.create!(phone_number: phone, code: code, expires_at: 10.minutes.from_now)
      begin
        client = Twilio::REST::Client.new
        client.messages.create(
          from: ENV["TWILIO_PHONE_NUMBER"],
          to: phone,
          body: "Your login OTP is: #{code}"
        )
      rescue => e
        render json: { status: { code: 500, message: "Failed to send OTP: #{e.message}" } }, status: :internal_server_error and return
      end
      render json: { status: { code: 200, message: "OTP sent to phone number." } }, status: :ok
    else
      render json: { status: { code: 401, message: "Invalid phone number" } }, status: :unauthorized
    end
  end

  def verify_otp
    @request.env["devise.mapping"] = Devise.mappings[:user]
    phone = params.dig(:user, :phone_number)
    code = params.dig(:user, :otp_code)
    otp = Otp.where(phone_number: phone, code: code).where("expires_at > ?", Time.current).first
    if otp
      user = User.find_by(phone_number: phone)
      if user
        # Issue JWT
        token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, resource_name, nil)
        refresh = user.refresh_tokens.create!
        render json: {
          status: { code: 200, message: "Logged in successfully." },
          data: {
            user: UserSerializer.new(user).serializable_hash[:data][:attributes],
            token: token,
            refresh_token: refresh.token,
            refresh_expires_at: refresh.expires_at
          }
        }, status: :ok
      else
        render json: { status: { code: 404, message: "User not found" } }, status: :not_found
      end
    else
      render json: { status: { code: 401, message: "Invalid or expired OTP" } }, status: :unauthorized
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
end
