class UserAccessesController < ApplicationController
  before_action :set_company, only: %i[new edit create]

  def new
    @user_access = UserAccess.new
  end

  def create
    @user_access = UserAccess.new(user_access_params)
    @user_access.company = @company
    user = User.find_by(email: @user_access.invitation_email)
    @user_access.user = user

    @user_access.access_type = if @company.user_accesses.empty?
                                 :owner
                               else
                                 :read
                               end

    if @user_access.save
      if user
        @user_access.update(is_valid: true)
      else
        UserMailer.with(user_access_id: @user_access.id).invitation_email.deliver_later
      end
    else
      render :form_error
    end
  end

  def update
    @user_access = UserAccess.find(params[:id])
    @company = @user_access.company
    @is_valid = params[:is_valid]
  end

  def destroy
    @user_access = UserAccess.find(params[:id])
    @company = @user_access.company
    @user_access.destroy
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def user_access_params
    options = params.require(:user_access).permit(:invitation_email, :user_id, :company_id)

    options.merge!(is_valid: false)

    options
  end
end
