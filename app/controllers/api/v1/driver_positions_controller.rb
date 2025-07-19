
class Api::V1::DriverPositionsController < ApiController
    before_action :authenticate_request

    def create
        position = DriverPosition.find_or_initialize_by(user: current_user)
        position.latitude = params[:latitude]
        position.longitude = params[:longitude]
        position.destination_latitude = params[:destination_latitude]
        position.destination_longitude = params[:destination_longitude]
        if position.save
            render json: { success: true }, status: :ok
        else
            render json: { errors: position.errors.full_messages }, status: :unprocessable_entity
        end
    end
end

