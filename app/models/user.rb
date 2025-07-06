class User < FilterableRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  mount_uploader :avatar, ImageUploader
  has_many :user_accesses
  has_many :companies, through: :user_accesses
  has_and_belongs_to_many :deliveries
  has_many :deals
  has_many :payments
  has_many :valid_client_companies, -> { where('user_accesses.is_valid = ?', true) }, through: :user_accesses, source: :company
  has_one  :user_setting
  has_many :archives
  has_many :withdrawal_receipts

  enum :role, %i[client delivery admin]
  enum :status, %i[active inactive locked]

  after_create :user_active_access, :create_setting

  validates :name, presence: true

  scope :scope_staff, -> { where(role: %i[delivery admin]) }

  def self.fetch(options = {})
    collection = super(options)
    collection = attribute_filter(collection, 'created_at', options)
    collection = attribute_filter(collection, 'role', options)
    collection = search_filter(collection, options)
    collection
  end

  def self.from_omniauth(auth)
    user = find_or_initialize_by(email: auth.info.email, provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name # assuming the user model has a name
      user.avatar = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      user.skip_confirmation! if auth.info.email_verified
    end

    return user unless user.id.nil?

    if exists?(email: auth.info.email)
      user.errors[:base] << 'El usuario no se encuentra registrado con google, intente con otro método'
    else
      user.save
    end

    user
  end

  def self.client?
    role == :client
  end

  def name_role
    "#{name} (#{role})"
  end

  def self.delivery?
    role == :delivery
  end

  def accessible_companies
    if client?
      valid_client_companies.pluck(:id)
    else
      :all
    end
  end

  def user_active_access
    user_accesses = UserAccess.where(invitation_email: email)
    return unless user_accesses.present?

    UserMailer.with(user_access: email).access_confirmation_email.deliver_later
    user_accesses.update_all(user_id: id, is_valid: true)
  end

  def deliveries_asigned
    Delivery.where(status: :asigned, user_asign_id: id)
  end

  def deliveries_asigned_count
    Delivery.where(status: :asigned, user_asign_id: id).count
  end

  def deliveries_access
    Delivery.where(company_id: valid_client_companies.ids)
  end

  def self.search_filter(collection, params)
    keys = %w[name email]

    return collection unless params[:query]

    queries = keys.map { |key| "REPLACE(LOWER(#{key}), ' ', '') LIKE REPLACE(LOWER('%#{params[:query]}%'), ' ', '')" }

    collection.where(queries.join(' OR '))
  end

  def self.find_or_create_by_google_oauth(email, google_uid, name = nil, picture = nil)
    user = find_by(email: email)

    if user
      # Si el usuario ya existe con ese email, asegúrate de que el google_uid esté asociado
      # y actualiza el nombre y la foto si están disponibles y no definidos.
      user.update(google_uid: google_uid) if user.google_uid.nil?
      user.update(name: name) if user.name.nil? && name.present?
      user.update(avatar_url: picture) if user.avatar_url.nil? && picture.present?
      user
    else
      # Crea un nuevo usuario
      create! do |new_user|
        new_user.email = email
        new_user.password = Devise.friendly_token.first(20) # Genera una contraseña aleatoria
        new_user.google_uid = google_uid
        new_user.name = name if name.present?
        new_user.avatar_url = picture if picture.present?
        # Otros campos que quieras inicializar para un nuevo usuario, por ejemplo:
        # new_user.role = :client
        # new_user.confirmed_at = Time.current # Si quieres confirmarlo automáticamente
      end
    end
  end

  def as_json_for_api(options = {})
    {
      id: id,
      email: email,
      name: name,
      role: role,
      avatar_url: avatar.url # Asumiendo que `avatar` es un uploader, si no, usa `avatar_url` directamente
    }
  end

  def create_setting
    UserSetting.create(user: self, show_delivery: :card)
  end

  def delivery_table?
    user_setting.list?
  end
end
