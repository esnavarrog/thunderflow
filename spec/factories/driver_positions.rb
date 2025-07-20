FactoryBot.define do
  factory :driver_position do
    user { nil }
    latitude { 1.5 }
    longitude { 1.5 }
    destination_latitude { 1.5 }
    destination_longitude { 1.5 }
  end
end
