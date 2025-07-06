class Deliveries::SetDeliveriesAddressService < ApplicationService

  def self.execute(delivery)
    return if delivery.address_concat.nil?
    
    coordenates = Maps::ApiMapsCoordenatesService.execute(delivery.address_concat)
    latitude = coordenates[0]
    longitude = coordenates[1]

    commune = coordenates[2]

    delivery.update_columns(commune: commune, latitude: latitude, longitude: longitude)
  end
end