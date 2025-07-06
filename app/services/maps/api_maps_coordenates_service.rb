class Maps::ApiMapsCoordenatesService < ApplicationService
    require 'json'
    require 'net/http'

    def self.execute(address)

        api_key = ENV['GOOGLE_MAPS_KEY']
        begin
            url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape(address)}&key=#{api_key}"

            uri = URI(url)
            response = Net::HTTP.get(uri)

            result = JSON.parse(response)
            latitude = result["results"][0]["geometry"]["location"]["lat"]
            longitude = result["results"][0]["geometry"]["location"]["lng"]

            components = result["results"][0]["address_components"]
            comuna = nil
            address_concat = result["results"][0]['formated_address']
            components.each do |component|
                if component["types"].include?("administrative_area_level_3")
                    comuna = component["long_name"]
                    break
                end
            end
        
            return latitude, longitude, comuna, address_concat
        rescue
            return nil, nil, nil, nil
        end

    end

    def self.distance(delivery)
        destination = "#{delivery.latitude},#{delivery.longitude}"
        origin = "#{delivery.branch.latitude},#{delivery.branch.longitude}"
        puts destination
        puts origin
        api_key = ENV['GOOGLE_MAPS_KEY']
        begin
            if delivery.latitude && delivery.longitude && delivery.branch.latitude && delivery.branch.longitude
                url_route = "https://maps.googleapis.com/maps/api/directions/json?origin=#{URI.encode(origin)}&destination=#{URI.encode(destination)}&key=#{api_key}"
                uri = URI(url_route)
                response_route = Net::HTTP.get_response(uri)
                result_route = JSON.parse(response_route.body)
                distance_in_meters = result_route['routes'][0]['legs'][0]['distance']['value']

                return distance_in_meters
            else
                return 1
            end
        rescue
            return 1
        end

    end
end