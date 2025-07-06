class AdministrativeAreasController < ApplicationController
  def regions; end

  def communes
    region_name = params[:region_name]
    @commune_price = params[:commune_price]

    @options = AdministrativeAreas.communes(region_name)
  end

  def price_deliveries
    commune = params[:commune]
    company = Company.find(params[:company_id])
    @price = 'No se ha proporcionado una comuna válida'
    return @price if commune.nil?

    price = set_price_for_commune(commune, company)
    @price = price ? "Precio estimado por comuna: #{ActionController::Base.helpers.number_to_currency((price / 1.19), precision: 0)} más IVA" : 'No tenemos covertura para esta comuna, ponte en contacto con ventas para mas información sobre coberturas'
  end

  private

  def set_price_for_commune(commune, company)
    commune_price = CommunePrice.where(commune: commune, name_profile: company.name_profile).first
    default_price = DefaultProfilePrice.find_by(name_profile: company.name_profile)

    commune_price&.price || default_price&.price || 0
  end
end
