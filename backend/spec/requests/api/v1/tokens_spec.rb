require 'swagger_helper'

RSpec.describe 'api/v1/tokens', type: :request do
  path '/api/v1/tokens/refresh' do
    post('refresh access token') do
      tags 'Authentication'
      description 'Exchange a valid refresh token for a new access (JWT) token'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :refresh, in: :body, schema: {
        type: :object,
        properties: {
          refresh_token: { type: :string }
        },
        required: [ 'refresh_token' ]
      }

      response(200, 'token refreshed') do
        schema type: :object,
               properties: {
                 access_token: { type: :string }
               }
        run_test!
      end

      response(401, 'invalid or expired refresh token') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
