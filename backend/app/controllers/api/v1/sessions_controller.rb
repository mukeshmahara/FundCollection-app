class Api::V1::SessionsController < Devise::SessionsController
  include RackSessionsFix
  respond_to :json

  private

  def respond_with(current_user, _opts = {})
    token = request.env['warden-jwt_auth.token'] # provided by devise-jwt
    render json: {
      status: { 
        code: 200,
        message: 'Logged in successfully.'
      },
      data: {
        user: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
        token: token
      }
    }, status: :ok
  end

  def respond_to_on_destroy
    token = request.headers['Authorization']&.split(' ')&.last
    user = nil
    if token.present?
      begin
        jwt_payload = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key || Rails.application.secret_key_base).first
        user = User.find_by(id: jwt_payload['sub'])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        user = nil
      end
    end

    if user
      render json: { status: 200, message: 'Logged out successfully.' }, status: :ok
    else
      render json: { status: 401, message: "Couldn't find an active session." }, status: :unauthorized
    end
  end
end
