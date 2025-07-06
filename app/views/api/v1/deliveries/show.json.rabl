object @delivery
attributes :id, :date_start, :status, :commune, :reference, :phone_number, :email,
          :dpto, :time_open, :time_close, :type_deliver, :address_concat,
          :complete_name, :description, :order_number, :longitude, :latitude

node :branch_name do
    @delivery.branch.name
end

node :branch_responsible_name do
    @delivery.branch.responsible_name
end

node :branch_contact_phone do
    @delivery.branch.phone_number
end

node :company_name do
    @delivery.company.name
end

node :status do
    enum_i18n(Delivery, :statuses, @delivery.status)
end