class AdditionalFee < FilterableRecord
  validates :additional_fee, presence: { message: 'Debes agregar un monto para el adicional' }
  validates :additional_type, presence: { message: 'Debes seleccionar un tipo de adicional' }
  validates :condition, presence: { message: 'Debes especificar la condición' }

  enum additional_type: [:minimum_requests]
  enum additional_model: [:deal, :company]
  enum name_profile: NAME_PROFILES_TYPES

  scope :scope_deals, -> { where(additional_model: :deal) }
  scope :scope_companies, -> { where(additional_model: :company) }

  def self.fetch(options)
    collection = super
    collection = attribute_filter(collection, 'additional_type', options)
    collection
  end
end