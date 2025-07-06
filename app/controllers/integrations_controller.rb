class IntegrationsController < ApplicationController
  before_action :set_branch, only:[:create, :new, :update, :load_orders]
  before_action :set_integration, only:[:update, :edit, :destroy, :load_orders, :create_orders]

  def index
    @integrations = @company.integrations
  end

  def new
    @integration = Integration.new
  end

  def create
    @integration = Integration.new(params_integration)
    @integration.company = @company
    render :form_error, status: 400 unless @integration.save
  end

  def edit
    @company = @integration.company
  end

  def update
    render :form_error, status: 400 unless @integration.update(params_integration.except(:token))
  end

  def destroy
    authorize @integration
    @integration.destroy
  end

  def load_orders
    @orders = @integration.api.get_orders
  end

  private
  def set_branch
    @branch = Branch.find_by(id: params[:branch_id])
    @company = Company.find_by(id: @branch.try(:company_id) || params[:company_id])
  end

  def set_integration
    @integration = Integration.find(params[:id] || params[:integration_id])
  end

  def params_integration
    params.require(:integration).permit(
      :name,
      :app_type,
      :url,
      :token,
      :consumer_key,
      :consumer_secret
    )
  end
end
