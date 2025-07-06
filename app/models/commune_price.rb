class CommunePrice < FilterableRecord
  validates :price, presence: { message: "El precio es requerido" }
  validates :commune, presence: { message: "La comuna es requerida" }
  validate :uniq_commune

  enum name_profile: NAME_PROFILES_TYPES

  scope :scope_estandar, -> { where(name_profile: :estandar) }
  scope :scope_premium, -> { where(name_profile: :premium) }
  scope :scope_express, -> { where(name_profile: :express) }

  def self.fetch(options = {})
    collection = super(options)
    collection = attribute_filter(collection, "commune", options)
    collection
  end

  def set_price
    self.price = price.gsub('.', '').to_i
  end

  def uniq_commune
    if CommunePrice.where(commune: commune, name_profile: name_profile).where.not(id: id).any?
      errors.add(:commune, "La comuna ya existe para este perfil de tarifa")
    end
  end
end
