require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'User ID'

    get('show user') do
      tags 'Users'
      description 'Retrieve user profile information'
      produces 'application/json'
      security [Bearer: []]

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/User'
        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(404, 'user not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    put('update user') do
      tags 'Users'
      description 'Update user profile information'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              email: { type: :string, format: :email }
            }
          }
        }
      }

      response(200, 'user updated') do
        schema '$ref' => '#/components/schemas/User'
        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(404, 'user not found') do
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
