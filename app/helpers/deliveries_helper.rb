module DeliveriesHelper
    def price_distance(distance)
        case distance.to_f.round
        when 0..8
            price = 3850
        when 9..11
            price = 4000
        when 12..15
            price = 4500
        when 16..20
            price = 5000
        when 21..24
            price = 6000
        when 25..26
            price = 7000
        when 27..30
            price = 8000
        else
            price = "No tenemos servicio para esta distancia"
        end
        price
    end
end
