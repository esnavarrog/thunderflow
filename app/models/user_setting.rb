class UserSetting < ApplicationRecord
  belongs_to :user

  enum show_delivery: [:card, :list]
end
