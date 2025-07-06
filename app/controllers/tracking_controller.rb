class TrackingController < ApplicationController

  def index
    @delivery = Delivery.find_by(order_number:params[:order_number]) if params[:order_number].present?
    @statuses = @delivery.statuses.where.not(status: [:preparing, :asigned, :rejected, :to_withdraw]) if @delivery
  end

  def show
  end

  def tracking_status
    number_tracking = params[:number_tracking].delete(' ')
    @delivery = Delivery.find_by(order_number:number_tracking)
    @statuses = @delivery.statuses.where.not(status: [:preparing, :asigned, :rejected, :to_withdraw]) if @delivery
    # @statuses = @delivery.statuses if @delivery
  end
end
