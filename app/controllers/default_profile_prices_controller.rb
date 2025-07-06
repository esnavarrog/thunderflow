class DefaultProfilePricesController < ApplicationController
  def create
    @default_price = DefaultProfilePrice.find_or_initialize_by(name_profile: default_price_params[:name_profile])
    @default_price.price = default_price_params[:price]

    respond_to do |format|
      if @default_price.save
        format.js
      else
        format.js { render :error }
      end
    end
  end

  private

  def default_price_params
    params.require(:default_price).permit(:name_profile, :price)
  end
end
