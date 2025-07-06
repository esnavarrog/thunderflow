class Woocommerce::NormalizedService < ApplicationService
  require 'json'
  # body es JSON.parse(response.body)
  def self.execute(body)
    body = JSON.parse(body.string)

    normalized = nil
    if body['shipping'].present?
      shipping = body['shipping']
      address = shipping['address_1']
      province = shipping['province']
      country = shipping['country']
      city = shipping['city']
      contact_name = shipping['first_name']
      contact_lastname = shipping['last_name']
      delivery = Delivery.find_by(integration_order_id: shipping['order_id'])
      coordenates = Maps::ApiMapsCoordenatesService.execute("#{address}, #{city}, #{province}, #{country}")
      address_concat = coordenates[3] || "#{address}, #{city}, #{province}, #{country}"
      latitude = shipping['latitude'] || coordenates[0]
      longitude = shipping['longitude'] || coordenates[1]
      commune = coordenates[2]

      normalized = {
        # name: shipping['order_key'],
        date_start: Time.parse(shipping['date_created']['date'])+1,
        description: body['line_items'].map { |line| "#{line['name']} Cantidad: #{line['quantity']}" }.join('/n'),
        contact_name: contact_name || contact_lastname,
        reference: shipping['shipping_total'],
        contact_lastname: contact_lastname,
        address_concat: address_concat,
        dpto: shipping['address_2'],
        phone_number: shipping['phone'],
        email: shipping['contact_email'] || shipping['email'],
        integration_order_id: shipping['order_id'],
        integration_type: :plugin_woocommerce,
        latitude: latitude,
        longitude: longitude,
        commune: commune || city
      }
    end
    normalized
  end
end
