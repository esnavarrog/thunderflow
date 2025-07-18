require 'mercadopago'
module MercadoPagoService
  include Rails.application.routes.url_helpers
  def self.initialize_sdk
    access_token = ENV['MERCADOPAGO_API_KEY']

    @mp = MercadoPago.new(access_token)
  end

  def self.mp_sdk
    @mp || initialize_sdk
  end

  def self.create_payment_preference(items_data, payer_data = {}, back_urls = {})
    sdk = mp_sdk

    items = items_data.map do |item|
      {
        title: item[:title],
        description: item[:description],
        quantity: item[:quantity],
        currency_id: item[:currency_id] || 'CLP', # Default to Argentine Pesos
        unit_price: item[:unit_price].to_f
      }
    end

    # Prepare payer data
    payer = {
      name: payer_data[:name],
      surname: payer_data[:surname],
      email: payer_data[:email],
      phone: {
        area_code: payer_data[:phone_area_code],
        number: payer_data[:phone_number]
      },
      address: {
        zip_code: payer_data[:address_zip_code],
        street_name: payer_data[:address_street_name],
        street_number: payer_data[:address_street_number]
      }
    }

    # Prepare back URLs for success, pending, and failure
    # Example:
    # back_urls = {
    #   success: "http://your_domain.com/payments/success",
    #   pending: "http://your_domain.com/payments/pending",
    #   failure: "http://your_domain.com/payments/failure"
    # }
    urlReturn = success_final_url(Rails.application.config.action_mailer.default_url_options)
    urlConfirmation = url_helpers.pay_success_url(app_host)

    default_back_urls = {
      success: urlReturn,
      pending: "http://localhost:3000/payments/pending", # Replace with your actual pending URL
      failure: "http://localhost:3000/payments/failure"  # Replace with your actual failure URL
    }

    preference_data = {
      items: items,
      payer: payer,
      back_urls: default_back_urls,
      auto_return: 'approved', # Automatically return to success URL on approved payment
      external_reference: "your_order_id_#{Time.now.to_i}" # Unique identifier for your order
      # You can add more parameters as needed, e.g., notification_url, payment_methods, etc.
      # See Mercado Pago API documentation for all available options.
    }

    begin
      preference = sdk.create_preference(preference_data)
      if preference['status'] == 201 || preference['status'] == 200
        # Success, return the preference object
        preference['response']
      else
        # Handle error
        Rails.logger.error "Mercado Pago Preference Creation Error: #{preference['response']}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "Mercado Pago SDK Error: #{e.message}"
      nil
    end
  end

  # Get payment details by ID
  def self.get_payment_details(payment_id)
    sdk = mp_sdk
    begin
      payment = sdk.get("/v1/payments/#{payment_id}")
      if payment['status'] == 200
        payment['response']
      else
        Rails.logger.error "Mercado Pago Get Payment Error: #{payment['response']}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "Mercado Pago SDK Error: #{e.message}"
      nil
    end
  end

  # You can add more methods here for other Mercado Pago operations, e.g.:
  # - Process refunds
  # - Manage customers and cards
  # - Handle webhooks (IPN - Instant Payment Notifications)
  # - ... and so on, depending on your application's needs.
end
