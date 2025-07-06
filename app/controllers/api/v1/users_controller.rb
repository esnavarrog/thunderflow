class Api::V1::UsersController < ApiController
  def me
    if @current_user
      render json: {
        id: @current_user.id,
        email: @current_user.email,
        name: @current_user.name,
        role: @current_user.role
      }, status: :ok
    else
      render json: { error: 'Not authenticated' }, status: :unauthorized
    end
  end
end