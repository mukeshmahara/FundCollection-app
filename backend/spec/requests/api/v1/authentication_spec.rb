require 'swagger_helper'

RSpec.describe 'api/v1/authentication', type: :request do
  path '/api/v1/login' do
    post('user login') do
      tags 'Authentication'
      description 'Authenticate user and return JWT token'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string }
            },
            required: [ 'email', 'password' ]
          }
        }
      }

      response(200, 'successful login') do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer },
                     message: { type: :string }
                   }
                 },
                 data: {
                   type: :object,
                   properties: {
                     user: { '$ref' => '#/components/schemas/User' },
                     token: { type: :string }
                   }
                 }
               }

        run_test!
      end

      response(401, 'invalid credentials') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/signup' do
    post('user registration') do
      tags 'Authentication'
      description 'Register a new user account'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string },
              password_confirmation: { type: :string },
              first_name: { type: :string },
              last_name: { type: :string }
            },
            required: [ 'email', 'password', 'password_confirmation', 'first_name', 'last_name' ]
          }
        }
      }

      response(201, 'successful registration') do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer },
                     message: { type: :string }
                   }
                 },
                 data: {
                   type: :object,
                   properties: {
                     user: { '$ref' => '#/components/schemas/User' },
                     token: { type: :string }
                   }
                 }
               }

        run_test!
      end

      response(422, 'invalid request') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/logout' do
    delete('user logout') do
      tags 'Authentication'
      description 'Logout user and invalidate JWT token'
      security [ Bearer: [] ]

      response(200, 'successful logout') do
        schema type: :object,
               properties: {
                 status: { type: :integer },
                 message: { type: :string }
               }

        run_test!
      end
    end
  end
end
