require 'swagger_helper'

RSpec.describe 'api/v1/webhooks', type: :request do
  path '/api/v1/webhooks/stripe' do
    post('stripe webhook') do
      tags 'Webhooks'
      description 'Stripe will POST events here. Provide raw payload & signature header.'
      consumes 'application/json'
      produces 'application/json'

      parameter name: 'Stripe-Signature', in: :header, type: :string, required: false, description: 'Stripe signature header'

      response(200, 'event processed (or ignored)') do
        schema type: :object,
               properties: {
                 status: { type: :string }
               }
        run_test!
      end

      response(400, 'invalid payload or signature') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
