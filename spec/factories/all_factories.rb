# Define NAME_PROFILES_TYPES for testing purposes
# This should match the actual enum definition in your Company model.
NAME_PROFILES_TYPES = [:estandar, :premium, :express].freeze

# A helper method to generate a basic valid Chilean RUT
# This function is placed outside any specific FactoryBot.define block
# but within the scope of the file so it can be called by multiple factories.
def generate_chilean_rut_for_test
  rut_body = rand(1_000_000..25_000_000) # Generate number between 1 million and 25 million
  sum = 0
  multiplier = 2
  rut_body.to_s.reverse.each_char do |digit|
    sum += digit.to_i * multiplier
    multiplier += 1
    multiplier = 2 if multiplier > 7
  end
  dv_num = 11 - (sum % 11)
  dv = case dv_num
       when 11 then '0'
       when 10 then 'K'
       else dv_num.to_s
       end
  "#{rut_body}-#{dv}"
end


# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { '123456' }
    name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    status { :active }
    term_and_conditions { true }
    rut { generate_chilean_rut_for_test } # Using the custom helper

    trait :delivery do
      role { :delivery }
    end

    trait :client do
      role { :client }
    end

    trait :admin do
      role { :admin }
    end

    trait :company_owner do
      role { :client }
      after(:create) do |user, evaluator|
        unless user.companies.exists?
          company = create(:company, owner: user)
          create(:user_access, user: user, company: company, access_type: :owner, is_valid: true)
        end
      end
    end
  end
end

# spec/factories/companies.rb
FactoryBot.define do
  factory :company do
    name { Faker::Company.unique.name }
    fantasy_name { Faker::Company.buzzword }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    commune { Faker::Address.city }
    address_concat { Faker::Address.full_address }
    rut { generate_chilean_rut_for_test } # Using the custom helper
    email { Faker::Internet.unique.email }
    status { :active }
    requires_additional_fee { false }
    client_type_payment { :shipping_without_payment }
    # Using the defined constant NAME_PROFILES_TYPES
    name_profile { NAME_PROFILES_TYPES.sample }

    association :owner, factory: [:user, :client]

    after(:create) do |company|
      unless company.user_accesses.exists?(user: company.owner, access_type: :owner)
        create(:user_access, user: company.owner, company: company, access_type: :owner, is_valid: true)
      end
    end
  end
end

# spec/factories/branches.rb
FactoryBot.define do
  factory :branch do
    name { Faker::Address.community }
    address_concat { "#{Faker::Address.street_address}, #{Faker::Address.city}, Chile" }
    commune { Faker::Address.city }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    association :company
    time_open { '09:00' }
    time_close { '18:00' }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 } # Added phone_number
  end
end

# spec/factories/deliveries.rb
FactoryBot.define do
  factory :delivery do
    weight { Faker::Number.between(from: 0.1, to: 50.0).to_s }
    height { Faker::Number.between(from: 1.0, to: 100.0).to_s }
    width { Faker::Number.between(from: 1.0, to: 100.0).to_s }
    depth { Faker::Number.between(from: 1.0, to: 100.0).to_s }
    date_start { Date.current + rand(1..7).days }
    commune { Faker::Address.city }
    reference { Faker::Lorem.sentence }
    phone_number { "9#{Faker::Number.unique.between(from: 10000000, to: 99999999)}" }
    contact_name { Faker::Name.first_name }
    contact_lastname { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    rut { generate_chilean_rut_for_test } # Using the custom helper
    time_open { '09:00' }
    time_close { '18:00' }
    time_deliver_open { '10:00' }
    time_deliver_close { '17:00' }
    address_concat { "#{Faker::Address.street_address}, #{commune}, Chile" }
    address_street { Faker::Address.street_name } # These are used for constructing address_concat in controller
    address_number { Faker::Address.building_number } # These are used for constructing address_concat in controller
    type_deliver { ['standard', 'express'].sample }
    complete_name { "#{contact_name} #{contact_lastname}" }
    description { Faker::Lorem.paragraph }
    longitude { Faker::Address.longitude.to_s }
    latitude { Faker::Address.latitude.to_s }
    status { Delivery.statuses.keys.excluding(:delivered, :returned, :rejected, :canceled, :nothing).sample }
    status_pay { :pending }
    shipping_without_payment { :yes }

    association :branch
    association :company
    association :user_asign, factory: [:user, :delivery]

    before(:create) do |delivery|
      delivery.company = create(:company) unless delivery.company
      delivery.branch = create(:branch, company: delivery.company) unless delivery.branch
      delivery.user_asign = create(:user, :delivery) unless delivery.user_asign
    end

    after(:create) do |delivery|
      create(:status, delivery: delivery, status: :preparing) unless delivery.statuses.any?
    end
  end
end

# spec/factories/statuses.rb
FactoryBot.define do
  factory :status do
    status { Delivery.statuses.keys.sample }
    observation { Faker::Lorem.sentence }
    image { nil }
    association :delivery
  end
end

# spec/factories/user_accesses.rb
FactoryBot.define do
  factory :user_access do
    access_type { UserAccess.access_types.keys.sample }
    invitation_email { Faker::Internet.email }
    is_valid { true }
    association :company
    association :user
  end
end

# spec/factories/user_settings.rb
FactoryBot.define do
  factory :user_setting do
    show_delivery { UserSetting.show_deliveries.keys.sample }
    association :user
  end
end
