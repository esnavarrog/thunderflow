class Company < FilterableRecord
  has_many :deliveries, dependent: :destroy
  has_many :branches, dependent: :destroy
  has_many :payments
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_many :user_accesses
  has_many :users, through: :user_accesses, source: :user
  has_many :resources, dependent: :destroy
  has_many :integrations, dependent: :destroy
  has_many :withdrawal_receipts
  has_many :deals

  validates :name, presence: { message: "Razón Social no puede estar en blanco" }
  validates :phone_number, presence: { message: "Tu contacto telefónico no puede estar en blanco" }
  validates :commune, presence: { message: "No puede estar en blanco" }
  validates :address_concat, presence: { message: "No puede estar en blanco" }
  validates :rut, presence: { message: "Rut no puede estar en blanco" }, uniqueness: { message: "Ya existe una empresa con este rut" }
  validates :email, presence:{ message: "Email no puede estar en blanco" },
              format:{ with: EMAIL_FORMAT, message: "Formato incorrecto" }
  validate :validate_rut, :validate_web_address
  before_validation :format_rut
  after_create :user_access_owner
  before_save :format_phone_number
  enum status: %i[active inactive locked]
  before_create :set_company_status, :set_requires_additional_fee
  enum client_type_payment: %i[shipping_with_payment shipping_without_payment]
  enum name_profile: NAME_PROFILES_TYPES

  def self.fetch(options = {})
    collection = super(options)
    collection = attribute_filter(collection, "user_id", options)
    collection = company_filter(collection, options)
    collection
  end

  def self.company_filter(collection, options)
    if options[:company_id].present?
      collection = collection.where(id:options[:company_id])
    end
    collection
  end

  def set_requires_additional_fee
    self.requires_additional_fee ||= false
  end

  def validate_rut
    unless rut.nil? || RUT::validate(rut)
        errors[:rut] << "El Rut no es válido"
    end
  end

  def validate_web_address
    unless web_address.blank?
      errors[:web_address] << "Debe ingresar una url válida" unless web_address =~ URI::regexp
    end
  end

  def format_rut
    self.rut = RUT::format(rut)
  end

  def user_access_owner
    UserAccess.create(user: owner, access_type: :owner, invitation_email:owner.email, company:self, is_valid:true)
  end

  def format_phone_number
    phone = phone_number.delete(" ").split("").last(9).join("")
    self.phone_number = phone
  end

  def generate_secret_key
    self.update_attribute(:secret_key, SecureRandom.hex)
  end

  def set_company_status
    self.status = :active unless status.present?
  end

  def klass_statuses
    case status
    when 'active'
      'success'
    when 'inactive'
      'primary'
    when 'locked'
      'warning'
    end
  end

  def set_additional_amount(deliveries)
    additional = AdditionalFee.scope_deals&.where(additional_type: :minimum_requests, name_profile: name_profile)&.last
    return { total_fee: 0, details: {} } if additional.nil?

    result = { total_fee: 0, details: {} }
    grouped_deliveries = deliveries.group_by { |d| d.date_start.to_date }
    condition_number = additional.condition&.to_i
    fee_amount = additional.additional_fee.to_i

    grouped_deliveries.each do |date, daily_deliveries|
      count = daily_deliveries.count
      fee = if requires_additional_fee && count < condition_number
              fee_amount
            else
              0
            end

      result[:details][date] = {
        deliveries_count: count,
        additional_fee: fee
      }
      result[:total_fee] += fee
    end

    result
  end

  def admins_emails
    admins_emails = user_accesses.where(is_valid: true).pluck(:invitation_email)
    admins_emails.join(", ")
  end

  def deliveries_promedium

    # Define the date range for the entire year 2025
    year_range = Date.new(2025, 1, 1).all_year

    # Count deliveries where date_start is within 2025
    total_deliveries_2025 = deliveries.where(date_start: year_range).count

    # Calculate the monthly average for 2025 and round it
    (total_deliveries_2025.to_f / 12).round(2)
  end

  def last_delivery_date
    deliveries.maximum(:date_start)
  end

  def delivery_status
    last_date = last_delivery_date
    return "Inactivo" if last_date.nil?

    if last_date < 2.months.ago
      "Inactivo"
    else
      "Activo"
    end
  end
end
