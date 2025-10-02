class DealsController < ApplicationController
  before_action :set_deal, only: %i[show edit update destroy export_deliveries update_archives]
  skip_before_action :verify_authenticity_token, only: [:show]
  require 'json'
  def index
    authorize :deal
    options = params
    options = options.merge({ limit: 20 })
    if current_user.client? && current_user.valid_client_companies.present?
      options = options.merge({ company_id: current_user.valid_client_companies.ids })
    end
    options = options.merge({ company_id: params[:company_id] }) if params[:company_id].present?
    options = options.merge({ only_save: false }) if current_user.client?
    options = options.merge({ order: 'created_at' })
    if params[:date_range].present?
      range = params[:date_range]
      range = range.gsub(' ', '').split('a')
      range = if range.length == 2
                Time.parse(range[0]).beginning_of_day..Time.parse(range[1]).end_of_day
              else
                Time.parse(range[0]).beginning_of_day..Time.parse(range[0]).end_of_day
              end
      options = options.merge({ created_at: range })
    end
    @deliveries = current_company.deliveries&.deliveries_not_payed if current_company && current_user.client?
    @deals = Deal.fetch(options)
  end

  def show
    @payment = @deal.payments.last if @deal.payments.present?
    options = { order: 'date_start', no_limit: true }
    @deliveries = @deal.deliveries.fetch(options)
  end

  def edit; end

  def new
    if current_user.admin?
      @companies = Company.all
    end
      @delivery = Delivery.find(params[:delivery_id]) if params[:delivery_id].present?
    if current_user.client?
      @deal = Deal.new
      @company = current_company
      @deliveries = @company.deliveries.deliveries_not_payed
      data = Deliveries::CalcPricesService.execute([Delivery.where(id: @deliveries.ids.to_a)].flatten, current_user, @company)
      @data = OpenStruct.new(data) if data.present?
    end
  end

  def select_company
    @company = Company.find(params[:company_id]) if params[:company_id].present?
    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id].first)
      @company = @branch.company
    end

    options = params
    options = options.merge({ branch_id: params[:branch_id].map(&:to_i) }) if params[:branch_id].present?
    options = options.merge({ no_limit: true })
    options = options.merge({ status_pay: 'pending', order: 'date_start' })

    @deliveries = @company.deliveries.fetch(options)

    # recordar de actualizar esta fecha de todas las solicitudes
  end

  def payed
    @deal = Deal.find(params[:id])
  end

  def rejected_pay
    @deal = Deal.find(params[:deal_id])
    return unless params[:form] == 'true'

    @deal.update(status_deal: :rejected, reason_rejected: params[:reason])
    DealMailer.rejected(current_user, @deal).deliver_later
  end

  def create
    deliveries = params[:ids].split(',').map { |id| Delivery.find(id) }
    data = OpenStruct.new(Deliveries::CalcPricesService.execute([deliveries].flatten, current_user, current_company)) if current_company.present? && current_user.client?
    update_params = params_deal
    company = Company.find(params_deal[:company_id])
    data = OpenStruct.new(Deliveries::CalcPricesService.execute([deliveries].flatten, current_user, company)) if current_user.admin?
    update_params = update_params.merge(put_data(data)) if data.present?
    update_params = update_params.merge({ only_save: params[:only_save] || false })
    @deal = Deal.new(update_params)
    authorize @deal
    additional_fee_data = @deal.company.set_additional_amount(deliveries)
    @deal.additional_amount = additional_fee_data[:total_fee]
    @deal.additional_details = additional_fee_data[:details]
    @deal.total_amount = deliveries.map{|a| a.price.to_i}.sum + @deal.additional_amount
    if @deal.save
      deliveries.each do |delivery|
        delivery.update_attribute(:deal_id, @deal.id)
      end
      redirect_to @deal
    else
      render :form_error
    end
  end

  def update
    authorize @deal
    if params[:deal].present? || params_deal[:status_deal].present? && params_deal[:pay_description].present?
      @pay_description = params_deal[:pay_description].present?
      @deal.update(params_deal)
    else
      data = OpenStruct.new(Deliveries::CalcPricesService.execute([@deal.deliveries].flatten || [], current_user, current_company)) if current_company.present? && current_user.client?
      update_params = params_deal
      company = Company.find(update_params[:company_id])
      data = OpenStruct.new(Deliveries::CalcPricesService.execute([@deal.deliveries].flatten || [], current_user, company)) if current_user.admin?
      update_params = update_params.merge(put_data(data)) if data.present?
      update_params = update_params.merge({ only_save: params[:only_save] || false })
      if @deal.update(update_params)
        respond_to do |format|
          format.js
          format.html { redirect_to deal_path }
        end
      else
        render :form_error
      end
    end
  end

  def send_notification
    @deal = Deal.find(params[:deal_id])
    @deal.update_attribute(:only_save, params[:only_save])
    @deal.company.user_accesses&.where(access_type: :owner)&.each do |user|
      DealMailer.update_deal(user.user_id, @deal).deliver_later if user.user_id && !@deal.only_save
    end
  end

  def update_archives
    authorize @deal
    count_archive = @deal.archives.count
    if @deal.update(params_deal)
      @count = @deal.archives.count - count_archive
    else
      render :form_error
    end
  end

  def put_data(data)
    return {} unless data.present?

     {
        total_amount: data.total_amount,
        total_cost: data.total_amount,
        utility: data.utility,
        iva: data.iva,
        additional_amount: data.additional_amount,
        additional_details: data.additional_details
     }
  end

  def download_deliveries_deal
    deliveries = Delivery.where(id: params[:select_ids])
    puts deliveries
    respond_to do |format|
      format.xlsx do
        @deliveries_xlsx = deliveries
        title = "Plantilla de solicitudes #{ApplicationController.helpers.format_date(Time.zone.now)}"
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=#{title}.xlsx"
      end
    end
  end

  def up_deliveries_deal
    deliveries = params[:delivery].to_unsafe_h.map { |_a, v| v }
    @deliveries = []
    deliveries.each do |item|
      delivery = Delivery.find(item['id'])
      delivery&.update(price: item['price'], price_deliver: item['price_deliver'])
      @deliveries << delivery if delivery&.pending? && delivery&.deal_id.nil?
    end
    return unless @deliveries.present?
    unless params[:prices]
      @company = @deliveries.last.company
      @companies = Company.all
      params[:company_id] = @company.id
    end
    @message = "Se han actualizado #{@deliveries.count} solicitudes."
    render :select_company
  end

  def get_result_prices
    @action_name = params[:action_name]
    @deal = Deal.find_or_initialize_by(id: params[:id])

    @ids = if @action_name == 'edit'
             @deal.deliveries.ids
           else
             params[:ids]
           end
    @company = Company.find(params[:company_id])
    data = Deliveries::CalcPricesService.execute([Delivery.where(id: @ids.to_a)].flatten, current_user, @company)

    if data.nil?
      render :calc_error
    else
      @data = OpenStruct.new(data)
    end
  end

  def export_deliveries
    respond_to do |format|
      format.xlsx do
        @deliveries_xlsx = @deal.deliveries
        title = "Cobro ##{@deal.id} de #{@deal.company.try(:name).try(:titleize)} #{ApplicationController.helpers.format_date(@deal.created_at)}"
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=#{title}.xlsx"
      end
    end
  end

  def set_deal
    @deal = Deal.find(params[:id])
  end

  def destroy
    authorize @deal
    return unless @deal.destroy

    @deal.deliveries.update_all(status_pay: :pending)
  end

  def upload_files
    @deal = Deal.find(params[:deal_id])
  end

  private

  def params_deal
    params.require(:deal).permit(
      :company_id,
      :status_deal,
      :total_amount,
      :total_cost,
      :utility,
      :descount,
      :pay_description,
      :additional_details,
      archives_attributes: [:id, :user_id, :file, :_destroy]
    )
  end

  def params_deliveries
    params.require(:delivery).permit(
      :id,
      :price,
      :price_deliver
    )
  end
end
