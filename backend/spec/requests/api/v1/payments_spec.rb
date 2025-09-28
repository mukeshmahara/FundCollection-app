require 'swagger_helper'

RSpec.describe 'api/v1/payments', type: :request do
  path '/api/v1/payments/create_payment_intent' do
    post('create payment intent') do
      tags 'Payments'
      description 'Create a Stripe payment intent for a donation'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :payment, in: :body, schema: {
        type: :object,
        properties: {
          donation_id: { type: :integer },
          return_url: { type: :string }
        },
        required: ['donation_id']
      }

      response(200, 'payment intent created') do
        schema type: :object,
               properties: {
                 client_secret: { type: :string },
                 payment_intent_id: { type: :string },
                 status: { type: :string }
               }

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(404, 'donation not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(422, 'invalid request') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/payments/confirm' do
    post('confirm payment') do
      tags 'Payments'
      description 'Confirm a payment and update donation status'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :payment, in: :body, schema: {
        type: :object,
        properties: {
          payment_intent_id: { type: :string }
        },
        required: ['payment_intent_id']
      }

      response(200, 'payment confirmed') do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 donation: { '$ref' => '#/components/schemas/Donation' }
               }

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(422, 'invalid request') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
