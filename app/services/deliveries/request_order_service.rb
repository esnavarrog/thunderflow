class Deliveries::RequestOrderService < ApplicationService
  EARTH_RADIUS_KM = 6_371.0

  def self.execute(deliveries, driver_lat, driver_lng)
    requests_data = deliveries.map do |req|
      {
        id:        req.id,
        latitude:  req.latitude,   # o req.location.latitude
        longitude: req.longitude   # o req.location.longitude
      }
    end

    @requests   = requests_data
    @driver_lat = driver_lat.to_f
    @driver_lng = driver_lng.to_f

    ordered_ids
  end

  def self.ordered_ids
    @requests
      .map { |r| r.merge(distance: haversine_distance(r[:latitude], r[:longitude])) }
      .sort_by { |r| r[:distance] }
      .map { |r| r[:id] }
  end

  private

  def self.haversine_distance(lat, lng)
    lat_rad1, lng_rad1 = @driver_lat * to_rad, @driver_lng * to_rad
    lat_rad2, lng_rad2 = lat.to_f * to_rad,   lng.to_f * to_rad

    dlat = lat_rad2 - lat_rad1
    dlng = lng_rad2 - lng_rad1

    a = Math.sin(dlat / 2)**2 +
        Math.cos(lat_rad1) * Math.cos(lat_rad2) * Math.sin(dlng / 2)**2

    2 * EARTH_RADIUS_KM * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end

  def self.to_rad
    Math::PI / 180
  end
end
