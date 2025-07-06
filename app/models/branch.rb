class Branch < FilterableRecord

  belongs_to :company
  has_many :deliveries, dependent: :destroy
  has_one :resource, dependent: :destroy
  validates :name, presence: {message: "Razon Social no puede estar en blanco"}
  validates :email, presence:{message: "Email no puede estar en blanco"},
              format:{ with: EMAIL_FORMAT, message: "Formato incorrecto"}
  validates :address_concat, presence: {message: "No puede estar en blanco"}
  after_save :lat_and_long
  
  before_save :format_phone_number
  enum status: %i[active inactive locked]

  def self.fetch(options = {})
    collection = super(options)
    collection = attribute_filter(collection, 'created_at', options)
    collection = branch_of_companies(collection, options)
    collection = user_filter(collection,options)
  end

  def self.user_filter(collection, params = {})
    if params[:user_id].present?
        companies = Company.where(user_id:params[:user_id]).ids
        collection = collection.where(company_id:companies)
    end
    collection
  end

  def self.branch_of_companies(collection, params= {})
    if params[:company_id].present?
      collection = collection.where(company_id:params[:company_id])
    end
    collection
  end

  def lat_and_long
    coordenates = Maps::ApiMapsCoordenatesService.execute(address_concat)
    self.update_column(:latitude, coordenates[0])
    self.update_column(:longitude, coordenates[1])
  end
  
  def format_phone_number
    phone = phone_number.delete(" ").split("").last(9).join("")
    self.phone_number = phone
  end

end
