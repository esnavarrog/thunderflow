class ShopifyApi
  def initialize(url, token, integration_id)
    @headers = {
      "Content-Type": "application/json",
      "X-Shopify-Access-Token": token
    }

    @url = url

    @url.chop! if @url.last == "/"
    @integration_id = integration_id
  end

  def get_orders
    path = '/admin/api/2023-07/orders.json'
    params = {
    }
    response = make_request('get', path, params)
  end

  private

  def make_request(method = 'get', path = "", params = {})
    body = params
    query_params = "?" + params.to_query

    if method.downcase != 'get'
      query_params = ""
    else
      body = nil
    end

    final_url = @url + path + query_params

    begin
      response = HTTParty.try(
        method.downcase.to_sym,
        final_url,
        body: body,
        headers: @headers,
        verify: !Rails.env.development?
      )
      validate_response(response)
    rescue => exception
      nil
    end
  end

  def validate_response(response)
    result = {}

    result = case response.code
             when 200
              normalize_body(JSON.parse(response.body))
             when 401
               { errors: "Token / Api key con error" }
             else
               { errors: "Error desconocido" }
             end

    result
  end

  def normalize_body(body)
    normalized = []

    if body['orders']
      normalized = body['orders'].map do |order|
        shipping_address = order['shipping_address'] || order['billing_address']
        address = shipping_address['address1']
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
          name: order['name'],
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