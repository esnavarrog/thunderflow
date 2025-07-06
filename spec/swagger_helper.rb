# spec/swagger_helper.rb
# ...
require 'rails_helper'
RSpec.configure do |config|
  # ...
  # Change this:
  # config.swagger_root = Rails.root.join('swagger').to_s
  # To this:
  config.openapi_root = Rails.root.join('swagger').to_s

  config.swagger_docs = { # DEPRECATED: Change to openapi_specs
                          # config.openapi_specs = { # New way
                          'v1/swagger.yaml' => {
                            openapi: '3.0.1',
                            info: {
                              title: 'API V1',
                              version: 'v1'
                            },
                            paths: {},
                            servers: [
                              {
                                url: 'http://{defaultHost}',
                                variables: {
                                  defaultHost: {
                                    default: 'localhost:3000'
                                  }
                                }
                              }
                            ],
                            components: {
                              securitySchemes: {
                                bearer_auth: {
                                  type: :http,
                                  scheme: :bearer,
                                  bearerFormat: :JWT
                                }
                              }
                            }
                          }
  }

  # Change this:
  # config.swagger_format = :yaml
  # To this:
  config.openapi_format = :yaml
  # ...
end