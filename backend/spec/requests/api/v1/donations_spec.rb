require 'swagger_helper'

RSpec.describe 'api/v1/donations', type: :request do
  path '/api/v1/donations' do
    get('list donations') do
      tags 'Donations'
      description 'Retrieve donations for the authenticated user'
      produces 'application/json'
      security [Bearer: []]
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/Donation' }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               }

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    post('create donation') do
      tags 'Donations'
      description 'Create a new donation'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :donation, in: :body, schema: {
        type: :object,
        properties: {
          donation: {
            type: :object,
            properties: {
              campaign_id: { type: :integer },
              amount: { type: :number, format: :decimal },
              anonymous: { type: :boolean }
            },
            required: ['campaign_id', 'amount']
          }
        }
      }

      response(201, 'donation created') do
        schema '$ref' => '#/components/schemas/Donation'
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

  path '/api/v1/donations/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Donation ID'

    get('show donation') do
      tags 'Donations'
      description 'Retrieve a specific donation by ID'
      produces 'application/json'
      security [Bearer: []]

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Donation'
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
    end
  end
end
