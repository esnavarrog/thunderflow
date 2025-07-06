class StatusesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_delivery, only: %i[new update]
  before_action :set_status, only: %i[show destroy]
  require 'json'
  def new
    @status = Status.new
    if current_user.delivery?
      desired_statuses = %w[retired delivered returned rejected]
      @statuses = Delivery.statuses.slice(*desired_statuses)
    else
      @statuses = Delivery.statuses unless current_user.delivery?
    end
  end

  def show; end

  def update; end

  def create
    deliveries = []
    errors = []

    return render :form_error if status_params[:status].nil?

    if params[:ids].present?
      ids = JSON.parse(params[:ids])
      ids.each do |id|
        delivery = Delivery.find(id)
        delivery.update_attribute(:price, params[:price]) if params[:price].present?
        delivery.update_attribute(:price_deliver, params[:price_deliver])
        deliveries << delivery
        status = Status.new(status_params)
        status.delivery = delivery
        status.user = current_user
        errors << status.errors.full_messages unless status.save
      end
    else
      delivery = Delivery.find(params[:delivery_id])
      delivery.update_attribute(:price, params[:price]) if params[:price].present?
      delivery.update_attribute(:price_deliver, params[:price_deliver])
      deliveries << delivery
      status = Status.new(status_params)
      status.delivery = delivery
      status.user = current_user
      status.save
      errors << status.errors.full_messages unless status.save
      options = params
      options = options.merge({ order: 'created_at' })
      @statuses = delivery.statuses.fetch(options) if delivery
    end

    @deliveries = deliveries
    return if errors.empty?

    render :form_error
  end

  def change_massive_status
    if current_user.delivery?
      desired_statuses = %w[retired delivered returned rejected]
      @statuses = Delivery.statuses.slice(*desired_statuses)
    else
      @statuses = Delivery.statuses unless current_user.delivery?
    end
    @status = Status.new
    @deliveries = params[:ids]
  end

  def destroy
    @statuses = @status.delivery.statuses.fetch(params)
    @status.destroy
  end

  def set_delivery
    @delivery = Delivery.find(params[:delivery_id])
  end

  def set_status
    @status = Status.find(params[:id])
  end

  private

  def status_params
    params.require(:status).permit(
      :image, :price, :price_deliver, :observation, :status, :receiver_phone, :receiver_rut, :receiver_name, :description
    )
  end
end
