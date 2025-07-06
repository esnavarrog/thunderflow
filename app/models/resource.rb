class Resource < FilterableRecord
  belongs_to :company
  belongs_to :branch

  validates :name, presence: {message: 'Por favor, es necesario que agregues un nombre.'}
  validates :branch_id, presence: {message: 'Es necesario que selecciones una sucursal.'}
  validates :web_address, presence: {message: 'Por favor, es necesario que agregues la dirección web.'}
  # validate :url_permit, on: :create

  enum status: [:active, :inactive, :locked]

  before_create :generate_access_token

  def self.fetch(options = {})
    collection = super(options)
    collection = attribute_filter(collection, 'created_at', options)
  end

  def generate_access_token
    payload = {
      branch_id: branch_id
    }
    crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'][0..31])
    token = crypt.encrypt_and_sign(payload)
    self.token = token
  end
  

  def url_permit
    unless /^https:\/\//.match?(web_address)
      errors[:web_address] << "Url no es válida, debe tener el prefijo https://"
    end
  end

  def check_resource_limit
    if company.resources.count >= 5
      errors[:resource_limit] << "No se pueden crear más recursos para esta cliente."
    end
  end

end
