class Deliveries::RouteGoogleService < ApplicationService
    require 'google_maps_service'
    def self.execute(current_user, point_start)

        client = GoogleMapsService::Client.new(key: ENV['GOOGLE_MAPS_KEY'])

        deliveries_asigned = current_user.deliveries_asigned

        waypoints = deliveries_asigned.pluck(:latitude, :longitude)

    end
end