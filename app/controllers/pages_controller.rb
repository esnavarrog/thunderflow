class PagesController < ApplicationController
  skip_before_action :validate_company

  layout "landpage"
  def landpage
    if current_user
      redirect_to welcome_index_url
    end
  end

  def new_contact; end

  def contact
    return unless params[:email].present?

    UserMailer.contact_landpage(email: params[:email], message: params[:message]).deliver_later
  end
end
