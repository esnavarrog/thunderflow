class Status < FilterableRecord
  mount_uploader :image, ImageUploader
  belongs_to :delivery
  belongs_to :user, optional: true
  validates :status, presence: { message: 'Debes seleccionar un estado' }

  enum status: STATUSES

  after_create :update_status_delivery, :send_notification

  def self.fetch(options = {})
    collection = super(options)
  end

  def send_notification
    return unless delivered? || in_route? || returned? || rejected?

    DeliveryMailer.status_deliveries(delivery_id).deliver_later if delivery.email.present?
  end

  def update_status_delivery
    delivery.update_attribute(:status, :in_route) if retired?
    delivery.update_attribute(:status, status) unless retired?
    delivery.update_attribute(:date_deliver_at, created_at)
    update_attribute :observation, "Estado cambiado a #{ApplicationController.helpers.enum_i18n(Status, :statuses, delivery.status)}"
  end

end
