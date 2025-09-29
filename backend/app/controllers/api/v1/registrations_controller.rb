class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :authenticate_user!, only: [ :create ]

  def create
    build_resource(sign_up_params)

    if resource.save
      # Manually issue JWT (stateless) so the client can be immediately authenticated.
      token, _payload = Warden::JWTAuth::UserEncoder.new.call(resource, resource_name, nil)
      render json: {
        status: { code: 201, message: "Signed up successfully." },
        data: {
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes],
          token: token
        }
      }, status: :created
    else
      render json: {
        status: {
          code: 422,
            message: "User couldn't be created successfully.",
            errors: resource.errors.full_messages
        }
      }, status: :unprocessable_entity
    end
  end

  private

    def sign_up_params
    permitted = [ :email, :password, :password_confirmation, :first_name, :last_name, :role ]
    if params[:user].is_a?(ActionController::Parameters)
      params.require(:user).permit(*permitted)
    else
      params.permit(*permitted)
    end
  end
end
