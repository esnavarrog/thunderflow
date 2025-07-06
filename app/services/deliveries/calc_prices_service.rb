class Deliveries::CalcPricesService < ApplicationService
    def self.execute(deliveries, user, company)
        if user.client? || !deliveries.map{|a| [a.price, a.price_deliver]}.flatten.include?(nil)
            additional_fee_data = company.set_additional_amount(deliveries)

            total_deliveries = deliveries.map{|a| a.price.to_i}.sum
            total_amount = total_deliveries + additional_fee_data[:total_fee]
            total_cost = deliveries.map{|a| a.price_deliver.to_i}.sum
            neto_amount = total_amount.to_f / 1.19
            iva = total_amount - neto_amount

            data = {
              total_amount: total_amount,
              total_deliveries_amount: total_deliveries,
              total_cost: total_cost,
              utility: total_amount - total_cost,
              iva: iva,
              neto_amount: neto_amount,
              additional_amount: additional_fee_data[:total_fee],
              additional_details: additional_fee_data[:details]
            }
        else
            data = nil
        end
        data
    end
end