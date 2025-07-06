# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["devise.auth_data"] = request.env["omniauth.auth"].except(:extra) # Removing extra as it can overflow some session stores
      failure
    end
  end

  def failure
    flash[:alert] = "Autenticación con Google fallida: #{params[:message]}"
    redirect_to new_user_session_path
  end
end