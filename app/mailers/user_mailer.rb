class UserMailer < ApplicationMailer
  def invitation_email
    @user_access = UserAccess.find(params[:user_access_id])
    @company = @user_access.company
    mail(to: @user_access.invitation_email, subject: 'Te invitamos a Altyro')
  end

  def access_confirmation_email
    @user_access = params[:user_access]
    mail(to: @user_access, subject: 'Confirmación de acceso aceptada')
  end

  def contact_landpage(email, message)
    @email = email
    mail(to: manager_emails(), subject: 'Un nuevo usuario intenta ponerse en contacto')
  end
end
