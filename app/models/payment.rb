class Payment < ApplicationRecord
	belongs_to :user, optional:true
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
		payment.status_message = "Pago realizado correctamente."
		payment.response_json = response.to_s
		payment.save
		payment
	end
end
