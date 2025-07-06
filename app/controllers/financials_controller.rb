class FinancialsController < ApplicationController
  def index
    authorize :financial
    @deliveries = Delivery.where(status: :delivered)
    @financial_report = @deliveries.where.not(price: nil, price_deliver: nil)
                                   .where("price ~ '^-?[0-9]+(?:\\.[0-9]+)?$' AND price_deliver ~ '^-?[0-9]+(?:\\.[0-9]+)?$'")
                                   .group_by_month(:date_start, range: 1.year.ago..Time.now, expand_range: true)
                                   .sum('(price::integer - price_deliver::integer)')
    @cost_report = @deliveries.where.not(price: nil, price_deliver: nil)
                              .where("price ~ '^-?[0-9]+(?:\\.[0-9]+)?$' AND price_deliver ~ '^-?[0-9]+(?:\\.[0-9]+)?$'")
                              .group_by_month(:date_start, range: 1.year.ago..Time.now, expand_range: true)
                              .sum('(price_deliver::integer)')
  end
end
