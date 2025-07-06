class PricesController < ApplicationController
  def index
    options = params
    options = options.merge({ no_limit: true })
    @deliveries = Delivery.fetch(options).where("price IS NULL OR price = '' OR price_deliver IS NULL OR price_deliver = ''").order(id: :desc)
  end

  def download_deliveries_price
    options = params
    options = options.merge({ no_limit: true })
    @deliveries = Delivery.fetch(options).where("price IS NULL OR price = '' OR price_deliver IS NULL OR price_deliver = ''").order(:id)
    respond_to do |format|
      format.xlsx do
        title = "Plantilla de solicitudes para editar #{ApplicationController.helpers.format_date(Time.zone.now)}"
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=#{title}.xlsx"
      end
    end
  end

  def up_deliveries_price
    deliveries = params[:delivery].to_unsafe_h.map { |_a, v| v }
    deliveries_update = []
    deliveries.each do |item|
      if item['price_deliver'].present? || item['price'].present?
        delivery = Delivery.find(item['id'])
        delivery&.update_column(:price, item['price']) unless item['price'].blank?
        delivery&.update_column(:price_deliver, item['price_deliver']) unless item['price_deliver'].blank?
        deliveries_update << delivery if delivery&.pending? && delivery&.deal_id.nil?
      end
    end
    return unless deliveries_update.present?
    @deliveries = Delivery.fetch({ no_limit: true }).where("price IS NULL OR price = '' OR price_deliver IS NULL OR price_deliver = ''").order(id: :desc)

    @message = "Se han actualizado #{deliveries_update.count} solicitudes."
  end
end
