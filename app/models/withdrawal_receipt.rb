class WithdrawalReceipt < FilterableRecord
  belongs_to :user, optional: true
  belongs_to :company, optional: true

  validates :company_id, presence: true
  validates :user_id, presence: true

  # after_create :send_email
  before_save :set_issued_at

  enum withdrawal_receipt_type: [:retired, :returned]

  def self.fetch(options = {})
    collection = super(options)
    collection = attribute_filter(collection, 'company_id', options)
    collection = attribute_filter(collection, 'user_id', options)
    collection = range_retired(collection, options)
    collection
  end

  def self.range_retired(collection, params = {})
    if params[:issued_at].present?
      date = Time.parse(params[:issued_at]).beginning_of_day..Time.parse(params[:issued_at]).end_of_day
      collection = collection.where(issued_at: date)
    end
    collection
  end

  def send_email
    WithdrawalReceiptMailer.new_withdrawal_receipt_email(id).deliver_later
  end

  def set_issued_at
    return if issued_at.present?

    self.issued_at = Time.zone.now
  end
end
