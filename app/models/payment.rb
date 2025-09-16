class Payment < ApplicationRecord
	belongs_to :user, optional: true
	belongs_to :company
	belongs_to :deal

	enum status: [:nothing, :pending, :payed, :rejected, :canceled]
	after_save :set_session_id

	def self.prepare_webpay(deal, user)
		payment = self.new
		payment.amount = deal.total_amount
		payment.company = deal.company
		payment.deal = deal
		payment.user = user || nil
		payment.description = "Pago de cobro #{payment.deal_id} por #{ActionController::Base.helpers.number_to_currency(payment.amount, precision:0, delimiter:".")}"
		payment.save
		payment
	end

	def set_session_id
		update_column(:session_id,"session-#{self.id}")
		update_column(:buy_order, "ordenDeCompra-#{self.id}")
	end

	def success_pay(response)
		response = JSON.parse(response.body)
		payment = self
		payment.fee = response["paymentData"]["fee"]
		payment.balance = response["paymentData"]["balance"]
		payment.pay_date = response["paymentData"]["date"]
		payment.payer = response["payer"]
		payment.media = response["paymentData"]["media"]
		payment.transfer_date = response["paymentData"]["transferDate"]
		payment.currency = response["currency"]
		payment.status = response["status"]
		payment.flow_order = response["flowOrder"]
		payment.status_message = case response["status"].to_i
			when 1
				"El pago está pendiente de confirmación"
			when 2
				"Pago realizado correctamente"
			when 3
				"El pago ha sido rechazado"
			when 4
				"El pago ha sido anulado"
			else
				"Estado de pago desconocido"
		end

		payment.response_json = response.to_s
		payment.save
		payment.deal.update(status_deal: payment.status)
		payment
	end

	def success_mp_pay(response)
		payment = self
		payment.fee = response["fee_details"][0]["type"]
		payment.balance = response["transaction_amount"]
		payment.pay_date = response["date_approved"]
		payment.payer = response["additional_info"]["payer"].to_s
		payment.currency = response["currency_id"]
		payment.status = response["status"] == 'approved' ? :payed : :pending
		payment.status_message = "Pago realizado correctamente."
		payment.response_json = response.to_s
		payment.save

		payment.deal.update(status_deal: payment.status)
		payment
	end
end
