class DeliveriesController < ApplicationController
  require 'roo'
  before_action :authenticate_user!
  before_action :set_branch, only: %i[create new new_deliver]
  before_action :set_delivery, only: %i[edit update destroy change_status_delivery]
  include DeliveriesHelper, ApplicationHelper

  def index
    authorize :delivery
    limit = current_user.admin? ? 300 : 20
    params[:limit] = limit if params[:limit].blank? || params[:limit].to_i.zero?
    @start_date = current_user.admin? && params[:date_range].blank? ? Time.zone.now.strftime("%d-%m-%Y") : params[:date_range]
    options = params
    options = options.merge({ status: params[:status] })
    options = options.merge({ date_range: @start_date }) unless @start_date.blank?
    options = options.merge({ commune: params[:communes].map{ |commune| commune.downcase } }) if params[:communes].present?
    options = options.merge({ user_asign_id: params[:user_asign_id].to_i }) if params[:user_asign_id].present?

    if current_user.delivery?
      options = options.merge({ user_asign_id: current_user.id })
      options = options.merge({ status: [:asigned, :in_route, :retired, :to_withdraw] }) if params[:status].blank?
      options = options.merge({ no_limit: true }) unless ['delivered'].include?(params[:status])
    end

    options = options.merge({ order: 'id' })
    options = options.merge({ dir: params[:direction] })
    options = options.merge({ company_id: current_user.valid_client_companies.ids }) if current_user.client?
    current_user.user_setting.update(show_delivery: params[:show_deliveries]) unless params[:show_deliveries].blank?

    options = options.merge({ payed: false }) if current_user.client?
    options = options.merge({ payed: params[:payed] || 'payed' }) if current_user.admin?

    options = options.merge({ client_type_payment: params[:client_type_payment] }) if params[:client_type_payment].present?

    @companies_deliveries = Company.all

    @deliveries = Delivery.fetch(options)
    @count_deliveries = @deliveries.count
    deliveries_report = Deliveries::ReportTodayAndTomorrowService.execute(current_user)
    @deliveries_today = deliveries_report[0]
    @deliveries_tomorrow = deliveries_report[1]
  end

  def show
    @delivery = Delivery.find(params[:id])
    authorize @delivery
    options = params.present? ? params : {}
    options = options.merge({ order: 'created_at' })
    @statuses = @delivery.statuses.fetch(options)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = DeliveryPdf.new(@delivery)
        send_data pdf.render,
                  filename: "solicitud_#{@delivery.id}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def new
    @delivery = Delivery.new
    @branch
  end

  def create
    @delivery = Delivery.new(params_delivery)
    authorize @delivery
    options = {}
    options = options.merge({ order: 'date_start' })
    @delivery.branch = @branch
    @delivery.phone_number = params_delivery[:phone_number].delete(' ').split('').last(9).join('')
    @delivery.status = :preparing
    @delivery.company = @branch.company
    @delivery.complete_name = "#{params_delivery[:contact_name]} #{params_delivery[:contact_lastname]}"

    @deliveries = @branch.deliveries.fetch(options)
    if @delivery.save
      DeliveryMailer.new_delivery(@delivery.company.owner.id, @delivery.id).deliver_later
    else
      render :form_error
    end
  end

  def change_status_delivery
    @status = @delivery.statuses.build
  end

  def save_prices
    @delivery = Delivery.find(params[:id])
    @delivery.update_columns(
      price: params[:price].gsub('.', ''),
      price_deliver: params[:price_deliver].gsub('.', '')
    )
  end

  def open_modal_download; end

  def download_deliveries
    options = params
    title = if params[:date_start].present? && params[:date_end].present?
              "Solicitudes de #{params[:date_start]} al #{params[:date_end]}"
            elsif params[:date_start].present? && !params[:date_end].present?
              "Solicitudes de #{params[:date_start]}"
            else
              "Solicitudes a la fecha #{Time.zone.now.strftime('%d-%m-%Y')}"
            end
    options = options.merge({ user_asign_id: current_user.id }) if current_user.delivery?
    options = options.merge({ status: [:asigned, :to_withdraw, :retired, :in_route] }) if current_user.delivery? && !params[:status].present?
    options = options.merge({ no_limit: true })
    @deliveries = Delivery.fetch(options)
    respond_to do |format|
      format.xlsx do
        response.headers[
          'Content-Disposition'
          ] = "attachment; filename=#{title}.xlsx"
      end
    end
  end

  def open_modal_ids; end

  def download_for_ids
    ids = params[:ids].gsub(' ', '').split(',')
    @deliveries = Delivery.where(id: ids)
    ids_text = params[:ids].gsub(' ', '').gsub(',', ' - ')
    title = "Solicitudes por ids #{ids_text}"
    respond_to do |format|
      format.xlsx do
        response.headers[
          'Content-Disposition'
          ] = "attachment; filename=#{title}.xlsx"
      end
    end
  end

  def request_xlsx
    options = params
    options = options.merge({ order: 'date_start', status: :preparing, no_limit: true })
    title = "#{params[:date_start]} - #{params[:date_end]}" if params[:date_start].present?
    respond_to do |format|
      format.xlsx do
        @deliveries = if params[:date_start].present? && params[:date_end].present?
                        Delivery.fetch(options)
                      else
                        Delivery.where(status: :preparing)
                      end
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=Solicitudes #{title}.xlsx"
      end
    end
  end

  def edit
    @branch = @delivery.branch
    if @delivery.preparing? || current_user.admin?
      render :edit
    else
      render :no_edit
    end
  end

  def update

    return if @delivery.update(params_delivery)

    render :form_error
  end

  def asign_user
    @delivery = Delivery.find(params[:id])
  end

  def asign_user_to_delivery
    deliveries = []
    if params[:ids].present?
      ids = JSON.parse(params[:ids])
      ids.each do |id|
        delivery = Delivery.find(id)
        delivery.update(user_asign_id: params[:user_id], status: :asigned)
        deliveries << delivery
        observation = "Repartidor #{User.find(params[:user_id]).email} asignado a la solicitud"
        Deliveries::CreateStatusService.execute(delivery, nil, params, current_user, observation)
      end
    else
      @delivery = Delivery.find(params[:delivery_id])
      observation = "Repartidor #{User.find(params[:user_id]).email} asignado a la solicitud"
      Deliveries::CreateStatusService.execute(@delivery, nil, params, current_user, observation)
      @delivery.update(user_asign_id: params[:user_id], status: :asigned)
      deliveries << @delivery
    end

    @deliveries = deliveries
    DeliveryMailer.notification_asigned(User.find(params[:user_id])).deliver_later

    @statuses = @delivery.statuses.fetch({ order: :created_at }) if @delivery
  end

  def asign_massive
    @status = Status.new
    if params[:branch_id].present?
      branch = Branch.find(params[:branch_id])
      @deliveries = branch.deliveries.where(status: :preparing).map(&:id) unless params[:status].present?
      @deliveries = branch.deliveries.where(status: params[:status]).map(&:id) if params[:status].present?
    else
      @deliveries = params[:ids]
    end
  end

  def destroy
    options = params
    options = options.merge({ status: params[:status] }) if params[:status].present?
    options = options.merge({ user_id: current_user.id }) if current_user.client?
    if current_user.delivery?
      options = options.merge({ user_asign_id: current_user.id,
                                status: params[:status].present? ? params[:status] : :asigned })
    end
    options = options.merge({ order: 'date_start' })

    @deliveries = @delivery.branch.deliveries.fetch(options)
    @delivery.destroy
  end

  def new_deliver
    @delivery = Delivery.new
  end

  def set_branch
    @branch = Branch.find(params[:branch_id])
  end

  def select_date; end

  def delivery_null_deal
    @delivery = Delivery.find(params[:id])
    authorize @delivery
    @deal = @delivery.deal_id if @delivery.deal_id.present?
    @delivery.update(deal_id: nil, status_pay: :pending)
  end

  def create_deliveries
    @branch = Branch.find(params[:branch_id])
    @integration = Integration.find_by(id: params[:integration_id])

    result = Deliveries::ImportService.execute(params, @branch, @integration)

    if result[:success]
      @deliveries = Delivery.fetch(id: result[:deliveries].map(&:id))
    else
      @errors = result[:errors]
      render :form_error_deliveries, status: :unprocessable_entity
    end
  end

  def price_for_distance
    price = price_distance(params[:distance])
    render json: { price: price }
  end

  def set_delivery
    @delivery = Delivery.find(params[:id])
  end

  def show_route
    if params[:branch_id]
      branch = Branch.find(params[:branch_id])
      latitude = branch.latitude
      longitude = branch.longitude
      point_start = "#{latitude}, #{longitude}"
    end
    point_start = params[:direction] if params[:direction]
    route = Deliveries::RouteGoogleService.execute(current_user, point_start)
  end

    private
    def params_delivery
        params.require(:delivery).permit(
            :width,
            :height,
            :weight,
            :depth,
            :description,
            :date_start,
            :date_end,
            :time_open,
            :time_close,
            :status,
            :address_street,
            :address_number,
            :address_concat,
            :latitude,
            :longitude,
            :distance_meters,
            :region,
            :dpto,
            :commune,
            :reference,
            :city,
            :phone_number,
            :contact_name,
            :contact_lastname,
            :email,
            :rut,
            :type_deliver,
            :time_deliver_open,
            :time_deliver_close,
            :time_open,
            :time_close,
            :price,
            :price_deliver,
            :user_asigned_id,
            :integration_order_id
        )
    end

  def status_params
    params.require(:status).permit(
      :image, :price, :price_deliver, :observation, :status, :receiver_phone, :receiver_rut, :receiver_name, :description
    )
  end
end
