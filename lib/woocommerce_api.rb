class WoocommerceApi
  require "json"
  def initialize(url, token)
    @url = url
    token = token.split(',')
    @consumer_key = token[0]
    @consumer_secret = token[1]
  end

  def get_orders
    endpoint = "/wp-json/wc/v3/orders"
    url = "#{@url}#{endpoint}"

    response = HTTParty.get(url, basic_auth: {username: @consumer_key, password: @consumer_secret})
    orders = JSON.parse(response.body)
    validate_response(response)
    normalize_body(orders)
  end

  private

  def validate_response(response)
    result = {}

    result = case response.code
             when 200
               normalize_body(JSON.parse(response.body))
             when 401
               { errors: "Token / Api key con error" }
             when 'woocommerce_rest_cannot_view'
               { errors: response.message }
             else
               { errors: "Error desconocido" }
             end

    result
  end
  def normalize_body(body)
    normalized = []

    if body['orders']
      normalized = body['orders'].map do |order|
        shipping_address = order['shipping']
        address = shipping_address['address_1']
        province = shipping_address['province']
        country = shipping_address['country']
        city = shipping_address['city']
        address_concat = "#{address}, #{city}, #{province}, #{country}"
        contact_name = shipping_address['first_name']
        contact_lastname = shipping_address['last_name']
        delivery = Delivery.find_by(integration_order_id: order['id'])
        coordenates = Maps::ApiMapsCoordenatesService.execute(address_concat)
        latitude = shipping_address['latitude'] || coordenates[0]
        longitude = shipping_address['longitude'] || coordenates[1]
        commune = coordenates[2]

        result = {
          delivery_id: delivery.try(:id),
          name: order['order_key'],
          date: Time.parse(order['created_at']),
          description: order['line_items'].map{ |line| line['name'] }.join('/n'),
          contact_name: contact_name || contact_lastname,
          contact_lastname: contact_lastname,
          address_concat: address_concat,
          city: city,
          province: province,
          phone_number: shipping_address['phone'],
          email: order['contact_email'],
          integration_order_id: order['id'],
          latitude: latitude,
          longitude: longitude,
          commune: commune
        }
      end
    end

    normalized
  end
end


