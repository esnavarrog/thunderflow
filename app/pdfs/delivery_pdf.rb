class DeliveryPdf < Prawn::Document
  def initialize(delivery)
    super(
      page_size: PrawnConfig::PAGE_SIZE,
      margin: PrawnConfig::MARGIN
    )
    @delivery = delivery
    header
    delivery_details
    footer
  end

  private

  def header
    text "Solicitud ##{@delivery.id}", align: :center, size: 16, style: :bold
    move_down 20
  end

  def delivery_details
    text "Fecha: #{I18n.l(@delivery.date_start, format: :long)}"
    move_down 20

    text "Destinatario", style: :bold
    move_down 10

    data = [
      ["Dirección:", @delivery.address_concat],
      ["Comuna:", @delivery.commune],
      ["Nombre:", @delivery.contact_name],
      ["Teléfono:", @delivery.phone_number]
    ]

    table(data, width: bounds.width) do |t|
      t.cells.borders = [:bottom]
      t.cells.border_width = 1
      t.cells.padding = [10, 5]
      t.column(0).font_style = :bold
      t.column(1).align = :right
    end
  end

  def footer
    move_down 50
    table([
            ["DEVELOPED BY", "https://www.birdti.cl/"],
            ["FOR", "https://sociosaltyro.cl/"]
          ], width: bounds.width) do |t|
      t.cells.borders = [:bottom]
      t.cells.align = :center
      t.cells.padding = [5, 5]
    end
  end
end