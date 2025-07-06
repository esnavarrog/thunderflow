class Deal < FilterableRecord
    belongs_to :company
    has_many :deliveries, dependent: :nullify
    has_many :payments, dependent: :nullify
    belongs_to :user, optional: true
    has_many :archives, as: :archiveable, dependent: :destroy
    accepts_nested_attributes_for :archives, allow_destroy: true
    MESSAGE = "No puede estar en blanco"

    enum status_deal: [:nothing, :pending, :payed, :rejected, :canceled]
    scope :deals_pending, -> { where.not(status_deal: [:payed, :rejected, :canceled]) }

    before_destroy :check_payments_existence
    before_create :set_status
    after_create :set_status_deliveries, :notification_to_users
    after_update :update_status_pay_delivery
    before_update :set_amounts

    def self.fetch(options = {})
        collection = super(options)
        collection = attribute_filter(collection,"company_id", options)
        collection = attribute_filter(collection,"created_at", options)
        collection = attribute_filter(collection,"status_deal", options)
        collection
    end

    def nothing?
        status_deal == :nothing.to_s || status_deal == nil
    end

    def set_status
        self.status_deal = 1
    end

    def additional_fee?
        company.requires_additional_fee
    end
    def update_status_pay_delivery
        if payed?
            deliveries.each do |delivery|
                delivery.update_column(:status_pay, :payed)
            end
        end
    end

    def set_status_deliveries
        deliveries&.each do |delivery|
            delivery.waiting!
        end
    end

    def notification_to_users
        company.user_accesses&.where(access_type: :owner)&.each do |user|
            DealMailer.new_deal(user.user_id, self).deliver_later unless self.only_save
        end
    end

    def neto_amount
        total_amount - iva
    end

    def set_total_amount

    end

    private
    def set_amounts
        additional_fee_data = company.set_additional_amount(deliveries)

        # Asignar directamente a los atributos sin update_columns
        self.total_cost = deliveries.map{|a| a.price_deliver.to_i}.sum
        self.additional_amount = additional_fee_data[:total_fee]
        self.additional_details = additional_fee_data[:details]

        total_deliveries = deliveries.map{|a| a.price.to_i}.sum
        self.total_amount = total_deliveries + additional_amount
        neto_amount = total_amount.to_f / 1.19
        self.iva = total_amount - neto_amount
        self.utility = total_amount - total_cost
    end

    def set_amounts_new
        additional_fee_data = company.set_additional_amount(deliveries)

        total_deliveries = deliveries.map{|a| a.price.to_i}.sum
        self.total_cost = deliveries.map{|a| a.price_deliver.to_i}.sum
        self.additional_amount = additional_fee_data[:total_fee]
        self.additional_details = additional_fee_data[:details]
        self.total_amount = total_deliveries + additional_amount
        neto_amount = total_amount.to_f / 1.19
        self.iva = total_amount - neto_amount
        self.utility = total_amount - total_cost

        # Usar update_columns para evitar callbacks y validaciones
        update_columns(
          total_cost: total_cost,
          additional_amount: additional_amount,
          additional_details: additional_details,
          total_amount: total_amount,
          iva: iva,
          utility: utility
        )
    end

    def check_payments_existence
        if payments.any?
            errors.add(:base, "No se puede eliminar el cobro porque existen pagos asociados.")
            throw :abort
        end
    end
end
