class BranchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_branch, only: [:show, :edit, :update]
  def index
    authorize :branch
    options = params
    options = options.merge({company_id: current_user.valid_client_companies.ids }) if current_user.client?
    options = options.merge({company_id: params[:company_id]}) if params[:company_id].present?
    options = options.merge({order: 'created_at'})
    @branches = Branch.fetch(options)
    @companies_search = current_user.client? ? @branches : Company.all
    @deliveries = current_company.deliveries&.deliveries_not_payed if current_user.client?
  end

  def new
    @branch = Branch.new
    @company = Company.find(params[:company_id])
  end

  def create
    @branch = Branch.new(params_branch)
    @branch.status = 0
    @company = Company.find(params_branch[:company_id])
    @branch.company = @company
    options = {}
    options = options.merge({order: 'id'})
    @branches = @company.branches.fetch(options)
    @delivery = Delivery.new
    if @branch.save
      render :create
    else
      render :form_error
    end
  end

  def edit
    @company = @branch.company
    
  end

  def update
    authorize @branch
    unless @branch.update(params_branch)
      render :form_error
    end
  end

  def show
    authorize @branch
    options = params
    options = options.merge({ limit: 20 })
    options = options.merge({ order: "created_at" })
    options = options.except(:id)
    @deliveries = @branch.deliveries.fetch(options)
    @start_date = current_user.admin? && params[:date_range].blank? ? Time.zone.now.strftime("%d-%m-%Y") : params[:date_range]
    respond_to do |format|
      format.xlsx {
          options = options.except(:limit)
          options = options.merge({ no_limit: true })
          @deliveries_xlsx = @branch.deliveries.fetch(options)
          title = "#{@branch.company.try(:fantasy_name)}-#{@branch.name} #{ApplicationController.helpers.format_date(@branch.created_at)}"
          response.headers[
          'Content-Disposition'
          ] = "attachment; filename=Solicitudes #{title}.xlsx"
        }
      format.html
      format.js
    end
  end

  def communes
    @communes = AdminDivision.communes(params[:region])
  end

  def branch_address
    @branch = Branch.find(params[:id]) if params[:id].present?
    if @branch
      render json: @branch
    else
      render json: {address_concat: ''}
    end
  end

  def get_deliver
    @company = Company.find(params[:company_id])
    @branches = @company.branches
  end

  def set_branch
    @branch = Branch.find(params[:id])
  end

  private
  def params_branch
    params.require(:branch).permit(
      :name,
      :phone_number,
      :street,
      :status,
      :email,
      :commune,
      :address_number,
      :address_concat,
      :responsible_name,
      :latitude,
      :longitude,
      :city,
      :country,
      :region,
      :dpto,
      :reference,
      :company_id,
      :time_open,
      :time_close,
      :default_price,
      :invert
    )
  end
end
