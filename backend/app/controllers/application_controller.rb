class ApplicationController < ActionController::API
  include Pagy::Backend
  # before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_response

  private

  def authenticate_user!
    super
  rescue JWT::DecodeError
    render json: { errors: [ "Invalid token" ] }, status: :unauthorized
  end

  def current_user_admin?
    current_user&.admin?
  end

  def require_admin!
    return if current_user_admin?

    render json: { errors: [ "Admin access required" ] }, status: :forbidden
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :role ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :avatar ])
  end

  def not_found_response(exception)
    render json: { errors: [ exception.message ] }, status: :not_found
  end

  def unprocessable_entity_response(exception)
    render json: {
      errors: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def unauthorized_response
    render json: { errors: [ "Not authorized to perform this action" ] }, status: :forbidden
  end

  def pagination_meta(pagy)
    {
      current_page: pagy.page,
      next_page: pagy.next,
      prev_page: pagy.prev,
      total_pages: pagy.pages,
      total_count: pagy.count,
      # pagy 6+ exposes :limit; older versions used :items accessor
      per_page: (pagy.respond_to?(:limit) ? pagy.limit : (pagy.vars[:items] || pagy.vars[:limit]))
    }
  end
end
