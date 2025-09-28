module Api
  module V1
    class BaseController < ApplicationController
      private

      def render_success(data, message = nil, status = :ok)
        response = { success: true, data: data }
        response[:message] = message if message
        render json: response, status: status
      end

      def render_error(errors, status = :unprocessable_entity)
        errors = [errors] unless errors.is_a?(Array)
        render json: { success: false, errors: errors }, status: status
      end

      def paginate_collection(collection, serializer_class)
        paginated = collection.page(params[:page]).per(params[:per_page] || 20)
        
        {
          items: serializer_class.new(paginated).serializable_hash[:data],
          meta: pagination_meta(paginated)
        }
      end
    end
  end
end
