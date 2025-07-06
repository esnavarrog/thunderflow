class DeliveryMailer < ApplicationMailer
  def new_delivery(user_id, delivery_id)
    @user = User.find(user_id)
    @delivery = Delivery.find(delivery_id)
    mail(to: @user.email, bcc: manager_emails(@user),
         subject: "Se ha creado una nueva solicitud de: #{@delivery.company.name}")
  end

  def new_deliveries(users, deliveries)
    users = User.where(id: users)
    @deliveries = Delivery.where(id: deliveries)
    users.each do |user|
      @user = user
      mail(to: @user.email, bcc: manager_emails(@user),
           subject: "Se han creado #{@deliveries.count} nuevas solicitudes para: #{@deliveries.last.company.name}")
    end
  end

  def status_deliveries(delivery_id)
    @delivery = Delivery.find(delivery_id)
    @status = @delivery.statuses.last
    if @status.rejected?
      user_email = @delivery.branch.email || @delivery.company.email
      return mail(to: user_email, subject: 'Hemos rechazado la solicitud')
    end

    user_email = @delivery.email
    user_name = @delivery.complete_name&.titleize
    subject = "#{user_name} hemos devuelto tu pedido" if @status.returned?
    subject = "#{user_name} hemos entregado tu pedido" if @status.delivered?
    subject = "#{user_name} tu pedido se encuentra en camino" if @status.in_route?
    mail(to: user_email, subject: subject)
  end

  def delivered(delivery_id)
    @delivery = Delivery.find(delivery_id)
    user_email = @delivery.email
    user_name = @delivery.complete_name&.titleize
    subject = "Entregamos tu pedido #{user_name}"
    manager_emails = manager_emails(User.find_by(email: user_email)) << @delivery.company.email
    mail(to: user_email, bcc: manager_emails, subject: subject)
  end

  def notification_asigned(user)
    @user = user
    @deliveries = Delivery.where(user_asign_id: user.id, status: :asigned)
    return unless @deliveries.present?

    subject = "Tienes #{@deliveries.count} nuevas solicitudes asignadas"
    mail(to: user.email, subject: subject)
  end
end
