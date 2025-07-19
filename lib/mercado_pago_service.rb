require 'mercadopago'
module MercadoPagoService
  def self.initialize_sdk
    access_token = ENV['MERCADOPAGO_SECRET_KEY']

    begin
      @mp = Mercadopago::SDK.new(access_token)
    rescue NameError => e
      Rails.logger.error "Mercado Pago SDK Initialization Error: #{e.message}. La clase 'MercadoPago' no fue encontrada. Asegúrate de que la gema 'mercadopago-sdk' esté instalada y cargada correctamente (ejecuta 'bundle install' y reinicia el servidor)."
      raise # Re-raise the error to make it visible
    rescue LoadError => e
      Rails.logger.error "Mercado Pago SDK Initialization Error: #{e.message}. No se pudo cargar la gema 'mercadopago'. Asegúrate de que esté en tu Gemfile y hayas ejecutado 'bundle install'."
      raise # Re-raise the error to make it visible
    rescue StandardError => e
      Rails.logger.error "Mercado Pago SDK Initialization Error: Un error inesperado ocurrió: #{e.message}"
      raise # Re-raise the error to make it visible
    end
  end

  def self.mp_sdk
    @mp || initialize_sdk
  end

  def self.create_payment_preference(payment)
    sdk = mp_sdk

    items = [
      {
        title: "Pago Solicitudes Despacho #{payment.deal_id}",
        description: payment.description,
        quantity: 1,
        currency_id: 'CLP',
        unit_price: payment.amount.to_i
      }
    ]

    payer = {
      name: payment.user.name,
      surname: payment.user.last_name,
      email: payment.user.email,
      phone: {
        area_code: "+56",
        number: payment.company.phone_number
      },
      address: {
        zip_code: "",
        street_name: payment.company.address_concat,
        street_number: payment.company.number_address
      }
    }

    url_helpers = Rails.application.routes.url_helpers
    app_host = ENV['HOST']
    preference_back_urls = {
      success: app_host+url_helpers.payment_success_path,
      pending: app_host+url_helpers.payment_pending_path,
      failure: app_host+url_helpers.payment_failure_path
    }

    preference_data = {
      items: items,
      payer: payer,
      back_urls: preference_back_urls,
      auto_return: 'approved',
      external_reference: payment.buy_order
    }

    preference_response = sdk.preference.create(preference_data)
    if preference_response[:status] == 201 || preference_response[:status] == 200
      return preference_response[:response]
    else
      Rails.logger.error "Mercado Pago Preference Creation Error: #{preference_response['response']}"
      nil
    end
  end

  def self.get_payment_details(payment_id)
    sdk = mp_sdk
    begin
      payment = sdk.payment.get(payment_id)
      if payment[:status] == 200
        payment[:response]
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
