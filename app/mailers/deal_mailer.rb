class DealMailer < ApplicationMailer
  def new_deal(user_id, deal)
    @deal = deal
    @user = User.find(user_id)
    mail(to: @user.email, cc: manager_emails(@user),
         subject: "Se ha creado un nuevo cobro para: #{@deal.company.name}")
  end

  def update_deal(user_id, deal)
    @deal = deal
    @user = User.find(user_id)
    mail(to: @user.email, cc: manager_emails(@user),
         subject: "Se actualizó el boton de pago para: #{@deal.company.name}")
  end

  def rejected(user, deal)
    @deal = deal
    mail(to: manager_emails(user), subject: "El cliente #{@deal.company.name} rechazó el cobro ##{@deal.id}")
  end
end
