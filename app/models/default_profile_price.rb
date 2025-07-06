class DefaultProfilePrice < ApplicationRecord
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :name_profile, presence: true, uniqueness: true
  enum name_profile: [:estandar, :premium, :express]
end
