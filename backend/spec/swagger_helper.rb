# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Fund Collection API',
        version: 'v1',
        description: 'API for managing fundraising campaigns and donations',
        contact: {
          name: 'API Support',
          email: 'support@fundcollection.com'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3001',
          description: 'Development server'
        },
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'api.fundcollection.com'
            }
          },
          description: 'Production server'
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string },
              first_name: { type: :string },
              last_name: { type: :string },
              role: { type: :string, enum: [ 'donor', 'admin' ] },
              created_at: { type: :string, format: :datetime },
              updated_at: { type: :string, format: :datetime }
            }
          },
          Campaign: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string },
              goal_amount: { type: :number, format: :decimal },
              deadline: { type: :string, format: :datetime },
              status: { type: :string, enum: [ 'draft', 'active', 'completed', 'cancelled' ] },
              creator_id: { type: :integer },
              created_at: { type: :string, format: :datetime },
              updated_at: { type: :string, format: :datetime }
            }
          },
          Donation: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              campaign_id: { type: :integer },
              amount: { type: :number, format: :decimal },
              anonymous: { type: :boolean },
              status: { type: :string, enum: [ 'pending', 'successful', 'failed', 'refunded' ] },
              created_at: { type: :string, format: :datetime },
              updated_at: { type: :string, format: :datetime }
            }
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string },
              message: { type: :string }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
