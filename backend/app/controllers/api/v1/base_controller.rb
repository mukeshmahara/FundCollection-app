module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_with_token!
      private

      # Authenticates user from Bearer token in Authorization header
      def authenticate_with_token!
        header = request.headers["Authorization"]
        if header.present? && header.start_with?("Bearer ")
          token = header.split(" ").last
          begin
            payload = Warden::JWTAuth::TokenDecoder.new.call(token)
            user = User.find_by(id: payload["sub"])
            if user
              @current_user = user
            else
              render_error("Invalid token: user not found", :unauthorized) and return
            end
          rescue JWT::DecodeError, ActiveRecord::RecordNotFound
            render_error("Invalid or expired token", :unauthorized) and return
          end
        else
          render_error("Missing Authorization header", :unauthorized) and return
        end
      end

      def current_user
        @current_user
      end

      def render_success(data, message = nil, status = :ok)
        response = { success: true, data: data }
        response[:message] = message if message
        render json: response, status: status
      end

      def render_error(errors, status = :unprocessable_entity)
        errors = [ errors ] unless errors.is_a?(Array)
        render json: { success: false, errors: errors }, status: status
      end

      def paginate_collection(collection, serializer_class)
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || Pagy::DEFAULT[:items]).to_i
        per_page = Pagy::DEFAULT[:max_items] if per_page > Pagy::DEFAULT[:max_items]
        pagy, records = pagy(collection, page: page, items: per_page)

        {
          items: serializer_class.new(records).serializable_hash[:data],
          meta: pagination_meta(pagy)
        }
      rescue Pagy::OverflowError
        # Return empty set with meta indicating overflow
        empty_pagy = Pagy.new(count: 0, page: 1, items: per_page)
        {
          items: [],
          meta: pagination_meta(empty_pagy).merge(error: "Page overflow")
        }
      end
    end
  end
end
