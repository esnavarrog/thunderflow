class ApplicationMailer < ActionMailer::Base
  CONTACT_EMAIL = "noreply@birdti.cl".freeze

  default from: "Altyro Envios <#{CONTACT_EMAIL}>"
  layout 'mailer'

  helper EmailHelper, ApplicationHelper, EnumI18nHelper

  def manager_emails(user)
    User.where(role: :admin).pluck(:email) - [user.email]
  end
end
