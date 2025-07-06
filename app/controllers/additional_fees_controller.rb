class AdditionalFeesController < ApplicationController
  before_action :set_additional_fee, only: [:edit, :destroy, :update]

  def index
    @additional_fees = AdditionalFee.fetch(params)
  end

  def new
    @additional_fee = AdditionalFee.new
  end

  def create
    @additional_fee = AdditionalFee.create(additional_fee_params)

    redirect_to additional_fees_path
  end

  def edit; end

  def update
    @additional_fee.update(additional_fee_params)

    redirect_to additional_fees_path
  end

  def destroy
    @additional_fee.destroy
  end

  private

  def set_additional_fee
    @additional_fee = AdditionalFee.find(params[:id])
  end

  def additional_fee_params
    params.require(:additional_fee).permit(
      :additional_fee,
      :additional_type,
      :additional_model,
      :condition,
      :name_profile
    )
  end
end
