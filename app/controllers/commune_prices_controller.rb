class CommunePricesController < ApplicationController
  before_action :set_commune_price, only: [:show, :edit, :update, :destroy]
  def index
    options = {}
    options = params
    options = options.merge({ no_limit: true })
    @commune_prices = CommunePrice.fetch(options)
  end

  def new
    @commune_price = CommunePrice.new
  end

  def create
    @commune_price = CommunePrice.new(commune_price_params)
    if @commune_price.save
      redirect_to commune_prices_path
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def destroy
    @commune_price.destroy
  end

  def update
    if @commune_price.update(commune_price_params)
      redirect_to commune_prices_path
    else
      render :edit
    end
  end

  private

  def set_commune_price
    @commune_price = CommunePrice.find(params[:id])
  end

  def commune_price_params
    params.require(:commune_price).permit(:commune, :price, :region_name, :name_profile)
  end
end
