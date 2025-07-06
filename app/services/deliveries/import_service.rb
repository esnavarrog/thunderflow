class Deliveries::ImportService
  def initialize(params, branch, integration)
    @params = params
    @branch = branch
    @integration = integration
    @errors = {}
    @deliveries = []
  end

  def self.execute(params, branch, integration)
    new(params, branch, integration).execute
  end

  def execute
    return failure_no_file unless @params[:file].present?

    validate_file
    process_excel
    return failure_with_errors if @errors.any?

    save_deliveries
    notify_users
    success
  rescue StandardError => e
    failure_system_error(e.message)
  end

  private

  def validate_file
    @xlsx = Roo::Excelx.new(@params[:file].tempfile.path, file_warning: :ignore)
  rescue StandardError => e
    @errors[1] = {
      messages: ['Archivo corrupto o con errores. Por favor descargue una nueva plantilla e inténtelo nuevamente.']
    }
    raise e
  end

  def process_excel
    @xlsx.sheet(@xlsx.sheets.first).drop(1).each_with_index do |row, index|
      break if row.nil? || row.compact.empty?

      begin
        delivery = build_delivery(clean_row(row))
        row_errors = validate_delivery(delivery, row)

        if row_errors.any?
          @errors[index + 2] = { messages: row_errors }
          next
        end

        @deliveries << delivery
      rescue StandardError => e
        @errors[index + 2] = { messages: ["Error en la fila #{index + 2}: #{e.message}"] }
      end
    end
  end

  def clean_row(row)
    row.map { |cell| cell.is_a?(String) ? cell.to_s.strip : cell }
  end

  def build_delivery(row)
    delivery_data = extract_delivery_data(row)

    Delivery.new(delivery_data).tap do |delivery|
      delivery.branch = @branch
      delivery.company = @branch.company
      delivery.region = "Metropolitana de Santiago"
      delivery.status = :preparing
      delivery.phone_number = format_phone_number(delivery_data[:phone_number]) || @branch.phone_number
      delivery.address_concat = generate_address(delivery_data)
      delivery.complete_name = "#{delivery_data[:contact_name]} #{delivery_data[:contact_lastname]}".strip
      delivery.integration_type = @integration&.app_type

      # Asegurar valores por defecto
      delivery.date_start ||= Date.current
      delivery.time_open ||= @branch.time_open
      delivery.time_close ||= @branch.time_close
    end
  end

  def extract_delivery_data(row)
    {
      contact_name: row[1].to_s.strip,
      contact_lastname: row[2].to_s.strip,
      email: row[4].to_s.strip,
      phone_number: row[5].to_s.strip,
      address_street: row[6].to_s.strip,
      address_number: row[7].to_i,
      dpto: row[8].to_s.strip,
      commune: row[10].to_s.strip,
      city: row[11].to_s.strip,
      height: row[13].presence || 0,
      width: row[14].presence || 0,
      depth: row[15].presence || 0,
      weight: row[16].presence || 0,
      time_open: parse_time(row[18]),
      time_close: parse_time(row[19]),
      time_deliver_open: parse_time(row[20]),
      time_deliver_close: parse_time(row[21]),
      reference: row[22].to_s.strip,
      description: row[23].to_s.strip,
      date_start: parse_date(row[0])
    }
  end

  def parse_date(value)
    return nil if value.blank?
    value.is_a?(Date) ? value : Date.parse(value.to_s)
  rescue StandardError
    Date.current
  end

  def parse_time(value)
    return nil if value.blank?
    value.is_a?(Time) ? value : Time.parse(value.to_s)
  rescue StandardError
    nil
  end

  def validate_delivery(delivery, row)
    errors = []
    errors << 'Falta nombre quien recibe' if delivery.contact_name.blank?
    errors << 'Falta número de teléfono de contacto' if row[5].blank?
    errors << 'Falta dirección de entrega' if delivery.address_street.blank?
    errors << 'Falta número dirección de entrega' if delivery.address_number.blank?
    errors << 'Falta comuna de entrega' if delivery.commune.blank?

    delivery.validate
    errors.concat(delivery.errors.full_messages)
    errors
  end

  def save_deliveries
    Delivery.transaction do
      @deliveries.each(&:save!)
    end
  end

  def notify_users
    DeliveryMailer.new_deliveries(
      @branch.company.users.ids,
      @deliveries.map(&:id)
    ).deliver_later
  end

  def format_phone_number(phone)
    return nil unless phone.present?
    phone.to_s.gsub(/[^0-9]/, '').last(9)
  end

  def generate_address(data)
    "#{data[:address_street]} #{data[:address_number]}, #{data[:commune]}, Chile"
  end

  def success
    {
      success: true,
      deliveries: @deliveries,
      errors: nil
    }
  end

  def failure_no_file
    {
      success: false,
      deliveries: nil,
      errors: { 1 => { messages: ['No se ha seleccionado ningún archivo'] } }
    }
  end

  def failure_with_errors
    {
      success: false,
      deliveries: nil,
      errors: @errors
    }
  end

  def failure_system_error(message)
    {
      success: false,
      deliveries: nil,
      errors: { 1 => { messages: ["Error del sistema: #{message}"] } }
    }
  end
end