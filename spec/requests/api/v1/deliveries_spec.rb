# spec/requests/api/v1/deliveries_spec.rb

require 'swagger_helper'

RSpec.describe 'Api::V1::Deliveries', type: :request do

  # Use let! for factories to ensure they are created before tests run
  let!(:courier_user) { create(:user, :delivery) } # User with 'delivery' role
  let!(:company_owner_user) { create(:user, :company_owner) } # User with 'company_owner' trait (and implicitly, 'client' role if not set by trait)
  # CORRECTED: Access the company through the 'companies' association and take the first one
  let!(:company) { company_owner_user.companies.first } # The company associated with the owner
  let!(:branch) { create(:branch, company: company) } # A branch belonging to that company

  # Mock authentication for all tests in this spec file.
  # This bypasses the actual token validation and directly sets `@resource.result` for tests.
  before do
    # Assuming `ApiController` has `authenticate_request` which sets `@resource`
    allow_any_instance_of(ApiController).to receive(:authenticate_request).and_return(true)

    # Stub the actual `@resource.result` to return a mock object that responds to `id` and `delivery?`
    # We will set the specific user for each test block
    allow_any_instance_of(ApiController).to receive(:@resource).and_return(
      instance_double(Object, result: instance_double(User, id: nil, delivery?: false)) # Default mock
    )
  end

  # Helper to set the current authenticated user for a specific test
  def set_current_user_for_test(user)
    allow_any_instance_of(ApiController).to receive(:@resource).and_return(
      instance_double(Object, result: user)
    )
  end

  path '/api/v1/deliveries' do
    get 'get deliveries found for courier' do
      tags 'Deliveries'
      produces 'application/json'
      security [bearer_auth: []] # Indicates that this endpoint requires authentication

      response '200', 'deliveries found' do
        let(:Authorization) { "Bearer mock_token_for_courier_#{courier_user.id}" }
        before do
          set_current_user_for_test(courier_user)
          create_list(:delivery, 3, user_asign: courier_user, company: company, branch: branch) # Create some deliveries for the courier
        end

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer, example: 1 },
                   weight: { type: :string, example: '5.0' },
                   height: { type: :string, example: '10.0' },
                   width: { type: :string, example: '10.0' },
                   depth: { type: :string, example: '10.0' },
                   date_start: { type: :string, format: 'date-time', example: '2025-01-01T10:00:00.000Z' },
                   date_end: { type: :string, format: 'date-time', example: '2025-01-01T18:00:00.000Z' },
                   status: { type: :string, example: 'asigned' },
                   commune: { type: :string, example: 'Santiago' },
                   reference: { type: :string, example: 'Near the big park' },
                   phone_number: { type: :string, example: '912345678' },
                   contact_name: { type: :string, example: 'Juan Perez' },
                   contact_lastname: { type: :string, example: 'contact_lastname' },
                   email: { type: :string, example: 'juan@example.com' },
                   rut: { type: :string, example: '12345678-9' },
                   address_concat: { type: :string, example: 'Av. Siempre Viva 742, Santiago, Chile' },
                   complete_name: { type: :string, example: 'Juan Perez' },
                   description: { type: :string, example: 'Fragile package' },
                   price: { type: :string, example: '5000' },
                   order_number: { type: :string, example: '1' },
                   status_pay: { type: :string, example: 'pending' },
                   longitude: { type: :string, example: '-70.6693' },
                   latitude: { type: :string, example: '-33.4489' },
                   integration_type: { type: :string, example: 'shopify' },
                   integration_order_id: { type: :string, example: '12345' },
                   shipping_without_payment: { type: :string, example: 'no' },
                   hour_delivery: { type: :string, example: 'Entre las 09:00 y 18:00' },
                   hour_retired: { type: :string, example: 'Entre las 10:00 y 17:00' },
                   name_user_asign: { type: :string, example: 'John Doe (delivery)' },
                   klass_statuses: { type: :string, example: 'primary' },
                   branch: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 10 },
                       name: { type: :string, example: 'Main Branch' },
                       address_street: { type: :string, example: 'Elm St' },
                       address_number: { type: :string, example: '123' },
                       commune: { type: :string, example: 'Springfield' },
                       latitude: { type: :string, example: '-33.4489' },
                       longitude: { type: :string, example: '-70.6693' }
                     }
                   },
                   company: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       name: { type: :string, example: 'Acme Corp' },
                       fantasy_name: { type: :string, example: 'Acme Logistics' }
                     }
                   }
                 }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(3)
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized access (not a delivery user)' do
        let(:client_user) { create(:user, :client) }
        let(:Authorization) { "Bearer mock_token_for_client_#{client_user.id}" }
        before do
          set_current_user_for_test(client_user)
        end
        schema type: :object, properties: { errors: { type: :array, items: { type: :string } } }
        run_test!
      end
    end

    post 'create a new delivery' do
      tags 'Deliveries'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :delivery, in: :body, schema: {
        type: :object,
        properties: {
          delivery: {
            type: :object,
            required: %w[weight height width depth date_start commune reference phone_number contact_name email address_street address_number branch_id],
            properties: {
              weight: { type: :string, example: '1.5' },
              height: { type: :string, example: '10' },
              width: { type: :string, example: '10' },
              depth: { type: :string, example: '10' },
              date_start: { type: :string, format: 'date', example: '2025-12-31' },
              commune: { type: :string, example: 'Las Condes' },
              reference: { type: :string, example: 'Next to the fountain' },
              phone_number: { type: :string, example: '987654321' },
              contact_name: { type: :string, example: 'Maria' },
              contact_lastname: { type: :string, example: 'Gonzalez' },
              email: { type: :string, example: 'maria@example.com' },
              rut: { type: :string, example: '9876543-2' },
              time_open: { type: :string, format: 'time', example: '09:00' },
              time_close: { type: :string, format: 'time', example: '17:00' },
              time_deliver_open: { type: :string, format: 'time', example: '10:00' },
              time_deliver_close: { type: :string, format: 'time', example: '16:00' },
              address_street: { type: :string, example: 'Av. Apoquindo' },
              address_number: { type: :string, example: '3000' },
              description: { type: :string, example: 'Delivery of documents' },
              type_deliver: { type: :string, example: 'standard' },
              branch_id: { type: :integer, example: 1 } # Use an existing branch ID
            }
          }
        },
        required: true
      }

      response '201', 'delivery created successfully' do
        let(:Authorization) { "Bearer mock_token_for_company_owner_#{company_owner_user.id}" }
        let(:delivery) { attributes_for(:delivery, company_id: company.id, branch_id: branch.id) }
        before do
          set_current_user_for_test(company_owner_user)
        end

        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 message: { type: :string, example: 'Solicitud creada correctamente.' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to be_present
          expect(response).to have_http_status(:created)
        end
      end

      response '422', 'invalid delivery parameters' do
        let(:Authorization) { "Bearer mock_token_for_company_owner_#{company_owner_user.id}" }
        let(:delivery) { { delivery: { weight: nil } } } # Invalid parameters
        before do
          set_current_user_for_test(company_owner_user)
        end
        schema type: :object, properties: { errors: { type: :array, items: { type: :string } } }
        run_test!
      end

      response '404', 'branch not found' do
        let(:Authorization) { "Bearer mock_token_for_company_owner_#{company_owner_user.id}" }
        let(:delivery) { attributes_for(:delivery, company_id: company.id, branch_id: 99999) } # Non-existent branch ID
        before do
          set_current_user_for_test(company_owner_user)
        end
        schema type: :object, properties: { message: { type: :string, example: 'Branch not found or does not belong to company.' } }
        run_test!
      end

      response '401', 'unauthorized to create for branch' do
        let(:Authorization) { "Bearer mock_token_for_courier_#{courier_user.id}" } # Courier cannot create deliveries
        let(:delivery) { attributes_for(:delivery, company_id: company.id, branch_id: branch.id) }
        before do
          set_current_user_for_test(courier_user)
        end
        schema type: :object, properties: { errors: { type: :array, items: { type: :string } } }
        run_test!
      end
    end
  end

  path '/api/v1/deliveries/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'id of delivery'

    get 'get delivery found' do
      tags 'Deliveries'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'delivery found' do
        let!(:delivery_record) { create(:delivery, user_asign: courier_user, company: company, branch: branch) }
        let(:id) { delivery_record.id }
        let(:Authorization) { "Bearer mock_token_for_courier_#{courier_user.id}" }
        before do
          set_current_user_for_test(courier_user)
        end
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 weight: { type: :string, example: '5.0' },
                 height: { type: :string, example: '10.0' },
                 width: { type: :string, example: '10.0' },
                 depth: { type: :string, example: '10.0' },
                 date_start: { type: :string, format: 'date-time', example: '2025-01-01T10:00:00.000Z' },
                 date_end: { type: :string, format: 'date-time', example: '2025-01-01T18:00:00.000Z' },
                 status: { type: :string, example: 'asigned' },
                 commune: { type: :string, example: 'Santiago' },
                 reference: { type: :string, example: 'Near the big park' },
                 phone_number: { type: :string, example: '912345678' },
                 contact_name: { type: :string, example: 'Juan Perez' },
                 contact_lastname: { type: :string, example: 'contact_lastname' },
                 email: { type: :string, example: 'juan@example.com' },
                 rut: { type: :string, example: '12345678-9' },
                 address_concat: { type: :string, example: 'Av. Siempre Viva 742, Santiago, Chile' },
                 complete_name: { type: :string, example: 'Juan Perez' },
                 description: { type: :string, example: 'Fragile package' },
                 price: { type: :string, example: '5000' },
                 order_number: { type: :string, example: '1' },
                 status_pay: { type: :string, example: 'pending' },
                 longitude: { type: :string, example: '-70.6693' },
                 latitude: { type: :string, example: '-33.4489' },
                 integration_type: { type: :string, example: 'shopify' },
                 integration_order_id: { type: :string, example: '12345' },
                 shipping_without_payment: { type: :string, example: 'no' },
                 hour_delivery: { type: :string, example: 'Entre las 09:00 y 18:00' },
                 hour_retired: { type: :string, example: 'Entre las 10:00 y 17:00' },
                 name_user_asign: { type: :string, example: 'John Doe (delivery)' },
                 klass_statuses: { type: :string, example: 'primary' },
                 branch: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 10 },
                     name: { type: :string, example: 'Main Branch' },
                     address_street: { type: :string, example: 'Elm St' },
                     address_number: { type: :string, example: '123' },
                     commune: { type: :string, example: 'Springfield' },
                     latitude: { type: :string, example: '-33.4489' },
                     longitude: { type: :string, example: '-70.6693' }
                   }
                 },
                 company: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     name: { type: :string, example: 'Acme Corp' },
                     fantasy_name: { type: :string, example: 'Acme Logistics' }
                   }
                 },
                 statuses: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       status: { type: :string, example: 'preparing' },
                       observation: { type: :string, example: 'Package is ready' },
                       created_at: { type: :string, format: 'date-time', example: '2025-01-01T09:00:00.000Z' },
                       image: { type: :string, nullable: true, example: 'url_to_image.jpg' }
                     }
                   }
                 }
               }

        run_test!
      end

      response '404', 'delivery not found' do
        let(:Authorization) { "Bearer mock_token_for_courier_#{courier_user.id}" }
        let(:id) { 99999 } # Non-existent ID
        before do
          set_current_user_for_test(courier_user)
        end
        schema type: :object, properties: { message: { type: :string, example: 'Delivery not found.' } }
        run_test!
      end

      response '401', 'unauthorized access to delivery' do
        let(:other_courier_user) { create(:user, :delivery) }
        let!(:delivery_record) { create(:delivery, user_asign: courier_user, company: company, branch: branch) }
        let(:id) { delivery_record.id }
        let(:Authorization) { "Bearer mock_token_for_other_courier_#{other_courier_user.id}" }
        before do
          set_current_user_for_test(other_courier_user)
        end
        schema type: :object, properties: { errors: { type: :array, items: { type: :string } } }
        run_test!
      end
    end

    patch 'update an existing delivery' do
      tags 'Deliveries'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :id, in: :path, type: :integer, description: 'id of delivery to update'
      parameter name: :delivery, in: :body, schema: {
        type: :object,
        properties: {
          delivery: {
            type: :object,
            properties: {
              status: { type: :string, example: 'retired' },
              description: { type: :string, example: 'Package picked up by courier' },
              # Add other updatable fields as needed
            }
          }
        }
      },
                required: true

      response '200', 'delivery updated' do
        let!(:delivery_record) { create(:delivery, user_asign: courier_user, company: company, branch: branch) }
        let(:id) { delivery_record.id }
        let(:Authorization) { "Bearer mock_token_for_courier_#{courier_user.id}" }
        let(:delivery) { { delivery: { status: 'retired', description: 'Package picked up' } } }
        before do
          set_current_user_for_test(courier_user)
        end

        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Solicitud actualizada correctamente.' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Solicitud actualizada correctamente.')
          expect(delivery_record.reload.status).to eq('retired')
          expect(response).to have_http_status(:ok)
        end
      end

      response '422', 'invalid update parameters' do
        let!(:delivery_record) { create(:delivery, user_asign: courier_user, company: company, branch: branch) }
        let(:id) { delivery_record.id }
        let(:Authorization) { "Bearer mock_token_for_courier_#{courier_user.id}" }
        let(:delivery) { { delivery: { status: 'invalid_status' } } } # Invalid status
        before do
          set_current_user_for_test(courier_user)
        end
        schema type: :object, properties: { errors: { type: :array, items: { type: :string } } }
        run_test!
      end

      response '404', 'delivery not found' do
        let(:Authorization) { "Bearer mock_token_for_courier_#{courier_user.id}" }
        let(:id) { 99999 } # Non-existent ID
        let(:delivery) { { delivery: { status: 'retired' } } }
        before do
          set_current_user_for_test(courier_user)
        end
        schema type: :object, properties: { message: { type: :string, example: 'Delivery not found.' } }
        run_test!
      end

      response '401', 'unauthorized to update delivery' do
        let(:other_courier_user) { create(:user, :delivery) }
        let!(:delivery_record) { create(:delivery, user_asign: courier_user, company: company, branch: branch) }
        let(:id) { delivery_record.id }
        let(:Authorization) { "Bearer mock_token_for_other_courier_#{other_courier_user.id}" }
        let(:delivery) { { delivery: { status: 'retired' } } }
        before do
          set_current_user_for_test(other_courier_user)
        end
        schema type: :object, properties: { errors: { type: :array, items: { type: :string } } }
        run_test!
      end
    end

    delete 'delete a delivery' do
      tags 'Deliveries'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :id, in: :path, type: :integer, description: 'id of delivery to delete'

      response '200', 'delivery deleted' do
        let!(:delivery_record) { create(:delivery, user_asign: courier_user, company: company, branch: branch) }
        let(:id) { delivery_record.id }
        let(:Authorization) { "Bearer mock_token_for_courier_#{courier_user.id}" }
        before do
          set_current_user_for_test(courier_user)
        end

        schema type: :object,
               properties: {
                 respuesta: { type: :integer, example: 1 },
                 message: { type: :string, example: 'Solicitud eliminada correctamente' },
                 idDelivery: { type: :integer, example: 101 }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['idDelivery']).to eq(id)
          expect(Delivery.find_by(id: id)).to be_nil
        end
      end

      response '404', 'delivery not found' do
        let(:Authorization) { "Bearer mock_token_for_courier_#{courier_user.id}" }
        let(:id) { 99999 } # Non-existent ID
        before do
          set_current_user_for_test(courier_user)
        end
        schema type: :object, properties: { message: { type: :string, example: 'Solicitud no encontrada.' } }
        run_test!
      end

      response '401', 'unauthorized to delete delivery' do
        let(:other_courier_user) { create(:user, :delivery) }
        let!(:delivery_record) { create(:delivery, user_asign: courier_user, company: company, branch: branch) }
        let(:id) { delivery_record.id }
        before do
          set_current_user_for_test(other_courier_user)
        end
        schema type: :object, properties: { errors: { type: :array, items: { type: :string } } }
        run_test!
      end
    end
  end
end
