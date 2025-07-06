# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  skip_before_action :validate_company

  def show
    super
  end
  # GET /resource/sign_in
  def new
    if Rails.env.development?
      sign_in(:user, User.first)
      return redirect_to welcome_index_url
    end

    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  def switch
    user = User.find_by(id: params[:user_id])
    sign_out
    sign_in(:user, user)
    redirect_to welcome_index_url
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
