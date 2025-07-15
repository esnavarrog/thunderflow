class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[create update edit show destroy]

  def index
    authorize :profile
    options = params
    options = options.merge({ order: 'created_at' })
    @profiles = User.fetch(options)
  end

  def show
    authorize @profile
    options = params
    options = options.merge({ order: 'created_at' })
    @companies = @profile.companies.fetch(options)
  end

  def edit; end

  def update
    if @profile.update(params_profile)
    else
      render :form_error
    end
  end

  def destroy
    authorize :profile
    @profile.destroy
  end

  def download_deliver_asigned
    user = User.find(params[:user_id])
    return if user.nil?

    @deliveries = user.deliveries_asigned
    title = "#{@deliveries.count} solicitudes asignadas a #{user.name || user.email}"
    respond_to do |format|
      format.xlsx do
        response.headers[
          'Content-Disposition'
          ] = "attachment; filename=#{title}.xlsx"
      end
    end
  end

  def set_profile
    @profile = User.find(params[:id])
  end

  def paginate_profiles
    options = {
      query: params[:query],
      role: params[:role],
      page: params[:page]
    }

    @profiles = User.fetch(options)
  end

  def confirmed_profile
    @user = User.find(params[:id])
    @user.update(confirmed_at: Time.now)
    redirect_to profiles_path
  end

  def add_password
    if current_user.update(password_params)
      render :add_password
    else
      @error = current_user.errors.full_messages.join('. ')
      render :error_password, status: :unprocessable_entity
    end
  end

  private
  def password_params
    params.permit(:password, :password_confirmation)
  end

  def params_profile
    params.permit(
      :name,
      :email,
      :avatar,
      :role,
      :status,
      :rut,
      :phone_number
    )
  end
end
