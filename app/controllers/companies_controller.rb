class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: [:show, :edit, :update, :see_secret_key, :charts_company]
  skip_before_action :validate_company, only: :create

  def index
    authorize :company
    options = params
    options = options.merge({order:'created_at'})
    options = options.merge({company_id: params[:company_id]}) if params[:company_id].present?
    @companies = current_user.client? ? current_user.companies.fetch(options) : Company.fetch(options)
    @companies_search = current_user.client? ? current_user.companies.fetch(options) : Company.all
  end

  def export
    options = params
    options = options.merge({no_limit: true})
    respond_to do |format|
      format.xlsx {
        @companies = Company.all.fetch(options)
        title = "#{ApplicationController.helpers.format_date(Time.zone.now)}"
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=Clientes #{title}.xlsx"
      }
    end
  end

  def show
    authorize @company
    options = {}
    options = options.merge({ order: "id", no_limit: true })
    @user_accesses = @company.user_accesses
    @branches = @company.branches.fetch(options)
    @resources = @company.resources.fetch(options)
    @integrations = @company.integrations
  end

  def xlsx_of_branches
    @company = Company.find(params[:company_id])
    options = params
    options = options.merge({ order: "created_at" })
    options = options.merge({ no_limit:true })
    respond_to do |format|
      format.xlsx {
          @deliveries_xlsx = @company.deliveries.fetch(options)
          title = "#{@company.try(:fantasy_name)} #{ApplicationController.helpers.format_date(Time.zone.now)}"
          response.headers[
          'Content-Disposition'
          ] = "attachment; filename=Solicitudes #{title}.xlsx"
        }
      format.html
    end
  end

  def report_for_client
    @company = Company.find(params[:company_id])
    options = params
    if params[:date_range].present?
      range = params[:date_range]
      range = range.gsub(' ', '').split('a')
      if range.length == 2
        options = options.merge(date_start: range[0], date_end: range[1])
      else
        options = options.merge(date_start: range[0], date_end: range[0])
      end
    end
    options = options.merge({ order: "date_start", dir: "asc" })
    options = options.merge({ status: :delivered })
    options = options.merge({ no_limit: true })
    respond_to do |format|
      format.xlsx do
        @deliveries = @company.deliveries.fetch(options)
        title = "#{@company.try(:fantasy_name)} #{params[:date_range]}"
        response.headers[
          'Content-Disposition'
          ] = "attachment; filename=Solicitudes #{title}.xlsx"
      end
    end
  end

  def report_client

  end

  def new
    @company = Company.new
  end

  def new_first_company
    @company = Company.new
  end

  def create
    @company = Company.new(params_company)
    @company.owner = current_user
    options = params
    if @company.save
      Branches::CreateBranchHouseService.execute(@company, options)
      redirect_to companies_path
    else
      render :form_error
    end
  end

  def edit
    
  end

  def update
    return if @company.update(params_company)

    render :form_error
  end

  def active_api
    @company = Company.find(params[:company_id])
    @company.update_attribute(:accepted_api,params[:accepted])
    @resources = @company.resources
  end

  def see_secret_key
    
  end

  def request_api_for_client
    @company = Company.find(params[:company_id])
    
    if @company.update(require_api:true)
      # enviar correo a fran o a mi para que autorice la conexión
    end
  end

  def charts_company
    deliveries = @company.deliveries
    case params[:chart_date]
    when 'mensual'
        @deliveries_chart = deliveries.where(status: :delivered).group_by_day(:date_start, range: 4.weeks.ago..Time.now, expand_range: true).count
    when 'semanal'
        @deliveries_chart = deliveries.where(status: :delivered).group_by_day(:date_start, range: 7.days.ago..Time.now, expand_range: true).count
    else
        @deliveries_chart = deliveries.where(status: :delivered).group_by_month(:date_start, last:12).count.transform_keys { |date| I18n.l(date, format: '%b').titleize }
    end
    if current_user.admin?
        case params[:chart_date]
        when 'mensual'
            @deliveries_price = deliveries.where(status: :delivered).where.not(price: [nil, "", "No tenemos servicio para esta distancia"]).group_by_day(:date_start, range: 4.weeks.ago..Time.now, expand_range: true).sum("price::integer")
        when 'semanal'
            @deliveries_price = deliveries.where(status: :delivered).where.not(price: [nil, "", "No tenemos servicio para esta distancia"]).group_by_day(:date_start, range: 7.days.ago..Time.now, expand_range: true).sum("price::integer")
        else
            @deliveries_price = deliveries.where(status: :delivered).where.not(price: [nil, "", "No tenemos servicio para esta distancia"]).group_by_month(:date_start, last: 12).sum("price::integer").transform_keys { |date| I18n.l(date, format: '%b').titleize }
        end
    end
  end

  def set_company
    @company = Company.find(params[:id])
  end

  def switch_current_company
    @company = Company.find_by(id: params[:company_id])
    session[:current_company_id] = @company.id
    redirect_to root_url
  end

  def update_settings_company
    @company = Company.find(params[:company_id])
    @company.update_column(:shipping_without_payment, params[:shipping_without_payment]) if params[:shipping_without_payment].present?
    @company.update_column(:requires_additional_fee, params[:requires_additional_fee]) if params[:requires_additional_fee].present?
    @company.update_column(:name_profile, params[:name_profile]) if params[:name_profile].present?
  end

  private
  def params_company
    params.require(:company).permit(
      :rut,
      :name,
      :fantasy_name,
      :address_number,
      :street,
      :address_concat,
      :latitude,
      :longitude,
      :commune,
      :dpto,
      :email,
      :phone_number,
      :web_address,
      :number_address,
      :status,
      :region,
      :responsible_name,
      :reference,
      :time_open,
      :time_close,
      :accepted_api,
      :automatic_payment,
      :shipping_without_payment,
      :requires_additional_fee
    )
  end
end
