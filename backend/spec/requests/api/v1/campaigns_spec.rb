require 'swagger_helper'

RSpec.describe 'api/v1/campaigns', type: :request do
  path '/api/v1/campaigns' do
    get('list campaigns') do
      tags 'Campaigns'
      description 'Retrieve all active campaigns'
      produces 'application/json'
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/Campaign' }
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
    end

    post('create campaign') do
      tags 'Campaigns'
      description 'Create a new fundraising campaign'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :campaign, in: :body, schema: {
        type: :object,
        properties: {
          campaign: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              goal_amount: { type: :number, format: :decimal },
              deadline: { type: :string, format: :datetime }
            },
            required: ['title', 'description', 'goal_amount', 'deadline']
          }
        }
      }

      response(201, 'campaign created') do
        schema '$ref' => '#/components/schemas/Campaign'
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

  path '/api/v1/campaigns/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Campaign ID'

    get('show campaign') do
      tags 'Campaigns'
      description 'Retrieve a specific campaign by ID'
      produces 'application/json'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Campaign'
        run_test!
      end

      response(404, 'campaign not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    put('update campaign') do
      tags 'Campaigns'
      description 'Update an existing campaign'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :campaign, in: :body, schema: {
        type: :object,
        properties: {
          campaign: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              goal_amount: { type: :number, format: :decimal },
              deadline: { type: :string, format: :datetime },
              status: { type: :string, enum: ['draft', 'active', 'completed', 'cancelled'] }
            }
          }
        }
      }

      response(200, 'campaign updated') do
        schema '$ref' => '#/components/schemas/Campaign'
        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(404, 'campaign not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(422, 'invalid request') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    delete('delete campaign') do
      tags 'Campaigns'
      description 'Delete a campaign'
      security [Bearer: []]

      response(204, 'campaign deleted') do
        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(404, 'campaign not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/campaigns/{id}/donate' do
    parameter name: 'id', in: :path, type: :string, description: 'Campaign ID'

    post('donate to campaign') do
      tags 'Campaigns'
      description 'Make a donation to a specific campaign'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :donation, in: :body, schema: {
        type: :object,
        properties: {
          donation: {
            type: :object,
            properties: {
              amount: { type: :number, format: :decimal },
              anonymous: { type: :boolean }
            },
            required: ['amount']
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

      response(404, 'campaign not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(422, 'invalid request') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/campaigns/{id}/donations' do
    parameter name: 'id', in: :path, type: :string, description: 'Campaign ID'

    get('list campaign donations') do
      tags 'Campaigns'
      description 'Retrieve all donations for a specific campaign'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'

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

      response(404, 'campaign not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
