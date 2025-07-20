class DriverPositionsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize DriverPosition
    respond_to do |format|
      format.html # renders app/views/driver_positions/index.html.erb
      format.json do
        @positions = DriverPosition.includes(:user).all
        render json: @positions.as_json(include: { user: { only: [:id, :name] } })
      end
    end
  end
end
