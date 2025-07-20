class Delivery < FilterableRecord
  belongs_to :branch
  belongs_to :company
  belongs_to :deal, optional: true
  has_many :statuses, dependent: :destroy

  include DeliveriesHelper

  has_and_belongs_to_many :users

  validates :address_concat, presence: { message: 'La dirección no puede estar en blanco' }
  validates :contact_name, presence: { message: 'El nombre del contacto no puede estar en blanco' }
  validates :phone_number, presence: { message: 'El número del contacto no puede estar en blanco' }
  validates :commune, presence: { message: 'Debes especificar la comuna de entrega' }
  validates :integration_order_id, uniqueness: true, allow_nil: true
  validates :status, presence: { message: 'Debes seleccionar un estado' }
  validate :company_active

  before_validation :merge_contact_name

  before_create :add_orden_number, :date_start_cannot_be_less_than_or_equal_to_current_date
  before_save :format_rut, :lat_and_long, :format_phone_number, :set_price_for_commune
  after_update :disabled_asign_user

  enum status: STATUSES
  enum status_pay: %i[pending waiting payed]
  FOR_DELIVER = %i[preparing asigned retired to_withdraw in_route returned rejected nothing]
  enum integration_type: %i[shopify plugin_woocommerce]
  enum shipping_without_payment: %i[no yes]


  scope :deliveries_not_payed, -> { where('date_start >= ?', Date.new(2025, 4, 15)).where.not(status_pay: :payed) }
  scope :deliveries_payed, -> { where(status_pay: :payed) }

  DELIVERY_COMPLETED_OR_CANCELED_STATUSES = %i[delivered returned rejected canceled nothing]

  scope :assigned_and_active_for_courier, ->(courier_id) {
    where(user_asign_id: courier_id)
      .where.not(status: DELIVERY_COMPLETED_OR_CANCELED_STATUSES)
      .order(date_start: :asc)
  }

  def self.fetch(options = {})
    collection = super(options)
    collection = search_filter(collection, %w[order_number address_concat commune complete_name], options)
    collection = range_date(collection, options)
    collection = attribute_filter(collection, 'branch_id', options)
    collection = attribute_filter(collection, 'company_id', options)
    collection = attribute_filter(collection, 'commune', options)
    collection = attribute_filter(collection, 'user_asign_id', options)
    collection = attribute_filter(collection, 'status', options)
    collection = attribute_filter(collection, 'status_pay', options)
    collection = attribute_filter(collection, 'id', options)
    collection = range_delivered(collection, options)
    collection = user_filter(collection, options)
    collection = company_filter(collection, %w[name fantasy_name], options)
    collection = payment_filter(collection, options)
    collection = check_payment_pending(collection, options)
    collection
  end

  def self.order_driver

  end

  def self.payment_filter(collection, params = {})
    collection = collection.where(deal_id: nil) if ['deal_not_present'].include?(params[:deal_present])
    collection = collection.where.not(deal_id: nil) if ['deal_present'].include?(params[:deal_present])
    return collection unless params[:deliveries_payed]

    collection = collection.deliveries_payed if ['yes_payed'].include?(params[:deliveries_payed])
    collection = collection.where.not(status_pay: :payed) if ['not_payed'].include?(params[:deliveries_payed])
    collection
  end

  def self.check_payment_pending(collection, options)
    return collection if options[:client_type_payment].blank?

    collection = collection.joins(:company).where('companies.shipping_without_payment = ?', options[:client_type_payment])
    collection
  end

  def self.user_filter(collection, params = {})
    if params[:user_id].present?
      companies = Company.where(user_id: params[:user_id])&.ids
      branches = Branch.where(company_id: companies)&.ids
      collection = collection.where(branch_id: branches)
    end
    collection
  end

  def self.range_delivered(collection, params = {})
    if params[:date_deliver_at].present?
      date = Time.parse(params[:date_deliver_at]).beginning_of_day..Time.parse(params[:date_deliver_at]).end_of_day
      collection = collection.where(date_deliver_at: date)
    end
    collection
  end

  def self.company_filter(collection, keys, params = {})
    if params[:company].present? && keys.present? && !keys.empty? && (keys.include?('name') || keys.include?('fantasy_name'))
      query = "companies.#{keys[0]} ILIKE unaccent('%#{params[:company]}%')"

      if keys.size > 1
        (1..keys.size - 1).each do |i|
          query += " or companies.#{keys[i]} ILIKE unaccent('%#{params[:company]}%')"
        end
      end
      collection.joins(:company).where(query)
    else
      collection
    end
  end

  def self.range_date(collection, params = {})
    if params[:date_end].present? && params[:date_start].present?
      date = Time.parse(params[:date_start]).beginning_of_day..Time.parse(params[:date_end]).end_of_day
      collection = collection.where(date_start: date)
    end
    if params[:date_end].present? && params[:date_start].empty?
      date = Time.parse(params[:date_end]).beginning_of_day..Time.parse(params[:date_end]).end_of_day
      collection = collection.where(date_start: date)
    end
    if params[:date_start].present? && !params[:date_end].present?
      date = Time.parse(params[:date_start]).beginning_of_day..Time.parse(params[:date_start]).end_of_day
      collection = collection.where(date_start: date)
    end
    if params[:date_range].present?
      range = params[:date_range]
      range = range.gsub(' ', '').split('a')
      range = if range.length == 2
                Time.parse(range[0]).beginning_of_day..Time.parse(range[1]).end_of_day
              else
                Time.parse(range[0]).beginning_of_day..Time.parse(range[0]).end_of_day
              end
      collection = collection.where(date_start: range)
    end
    collection
  end

  def status_preparing?
    preparing? || asigned? || to_withdraw?
  end

  def status_rute?
    retired? || in_route?
  end

  def format_rut
    self.rut = RUT.format(rut) if rut_changed?
  end

  def user_asign
    User.find(user_asign_id) if user_asign_id
  end

  def name_user_asign
    return unless user_asign_id

    user = User.find(user_asign_id)
    name = user.name.to_s
    name = user.email unless name.present?
    name
  end

  def email_user_asign
    return unless user_asign_id

    user = User.find(user_asign_id)
    user.email
  end

  def next_status_destiny
    if ["asigned", "retired", "to_withdraw"].include?(status.to_s)
      :in_route
    elsif ["in_route"].include?(status.to_s)
      :delivered
    end
  end

  def next_status_preparing
    if ["asigned", "retired", "to_withdraw"].include?(status.to_s)
      :rejected
    elsif ["in_route"].include?(status.to_s)
      :rejected
    end
  end

  def klass_statuses
    case status
    when :delivered.to_s
      'success'
    when :asigned.to_s
      'info'
    when :in_route.to_s
      'in_route'
    when :retired.to_s
      'info'
    when :preparing.to_s
      'secondary'
    when :returned.to_s
      'danger'
    when :rejected.to_s
      'danger'
    when :no_retired.to_s
      'danger'
    else
      'set'
    end
  end

  def date_start_cannot_be_less_than_or_equal_to_current_date
    return unless date_start.nil? || date_start.present? && date_start.to_date < Date.current

    self.date_start = Date.current
  end

  def merge_contact_name
    return unless complete_name_changed?

    name = "#{contact_name} #{contact_lastname}"
    self.complete_name = name
  end

  def lat_and_long
    return unless address_concat_changed?

    coordenates = Maps::ApiMapsCoordenatesService.execute(address_concat)
    distance_meters = Maps::ApiMapsCoordenatesService.distance(self)
    self.latitude = coordenates[0] if latitude.nil?
    self.longitude = coordenates[1] if longitude.nil?
    self.distance_meters = distance_meters if distance_meters.nil?
    self.commune = coordenates[2] if commune.nil? || commune.empty?
  end

  def format_phone_number
    return unless phone_number_changed?

    phone = phone_number.delete(' ').split('').last(9).join('')
    self.phone_number = phone
  end

  def add_orden_number
    self.order_number = generate_token
  end

  def generate_token
    loop do
      token = SecureRandom.hex(5)
      break token unless Delivery.where(order_number: token).exists?
    end
  end

  def finish?
    delivered? || returned?
  end

  def hour_delivery
    hour_start = time_deliver_open&.strftime("%H:%M")
    hour_end = time_deliver_close&.strftime("%H:%M")
    result = if hour_start.present? && hour_end.present?
               "#{hour_start} - #{hour_end}"
             else
               hour_start || hour_end
             end
    result
  end

  def hour_retired
    hour_start = time_open.present? ? time_open&.strftime("%H:%M") : branch.time_open&.strftime("%H:%M")
    hour_end = time_close.present? ? time_close&.strftime("%H:%M") : branch.time_close&.strftime("%H:%M")
    result = if hour_start.present? && hour_end.present?
               "#{hour_start} - #{hour_end}"
             else
               hour_start || hour_end
             end
    result
  end

  def company_active
    return if company.active?

    errors.add(:company, 'No puedes agendar debido a que la empresa se encuentra bloqueada por administrador') if company.locked?
    errors.add(:company, 'No puedes agendar debido a que la empresa no se encuentra activa') if company.inactive?
  end

  def is_payed?(current_user)
    return if current_user&.admin?

    # errors.add(:payed, "No podemos editar una solicitud pagada") if payed? && deal.payed?
  end

  def qr_code_svg
    qrcode = RQRCode::QRCode.new(self.id.to_s)

    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 3,
      standalone: true
    )
  end

  def disabled_asign_user
    if preparing?
      update_column(:user_asign_id, nil)
    end
  end

  def set_price_for_commune
    commune_price = CommunePrice.where(commune: commune, name_profile: company.name_profile).first
    default_price = DefaultProfilePrice.find_by(name_profile: company.name_profile)

    return if commune_price.present? && price === commune_price.price

    self.price = if commune_price.present?
                   commune_price.price
                 elsif default_price.present?
                   default_price.price
                 else
                   0
                 end
  end

end
