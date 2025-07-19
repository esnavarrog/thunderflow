class PaymentsController < ApplicationController
	skip_before_action :verify_authenticity_token, only:[:success_final, :pay_success]
	before_action :authenticate_user!, only: [:new, :create]
	require 'openssl'
	require 'base64'
	require 'json'

	def new
		@payment = Payment.new
        @deal = Deal.find(params[:deal_id])
	end

	def create
		@deal = Deal.find(params[:deal_id])
		user = current_user.present? ? current_user : nil

		@payment = Payment.prepare_webpay(@deal, user)
		if params[:payment_method] == 'mercadopago'
			response = MercadoPagoService.create_payment_preference(@payment)
			token = response['id']
			@payment.update(token: token) if @payment.present? and token.present?
			redirect_to response['init_point'], allow_other_host: true
		else
			response = Flow.init_transaction(@payment)
			if response && response['token'].present? && response['url'].present?
				token = response['token']
				url   = response['url']
				@payment.update(token:token) if @payment
				redirect_to url + "?token=" + token, allow_other_host: true
			else
				redirect_to root_path, alert: "Error al procesar el pago. Por favor, inténtelo de nuevo más tarde."
			end
		end

	end

	# Función que presenta un resumen del pago
	def pay_success
		response = Flow.success_flow(params)
	end
	#Función que despliega una vista, indicando un error en la transacción
	def webpay_error
		webpay_success
	end
	# Función que despliega información en el caso que el usuario haya cancelado la transacción
	def webpay_nullify
		webpay_success
	end

	def webpay_return_url; end

	# def success_final
	# 	response = Flow.success_flow(params)
	# 	if response.code == 200
	# 		@payment = Payment.where(token:params['token']).lock(true).take
	# 		@payment = @payment.success_pay(response)
	# 		params_response = JSON.parse(response.body)
	#
	# 		unless @payment.media.nil?
	# 			@user = @payment.user if @user.present?
	# 			@payment.deal.update(status_deal: params_response["status"])
	# 			@response = response
	# 		else
	# 			@payment.deal.update(status_deal: params_response["status"])
	# 			@payment.update(status_message:"Pago no realizado por algún error...")
	# 		end
	# 		redirect_to @payment.deal, status: 200
	# 	end
	# end

	def success_final
		response = Flow.success_flow(params)

		if response&.code == 200
			@payment = Payment.where(token: params['token']).lock(true).take

			if @payment.nil?
				flash[:error] = "No se encontró el pago asociado"
				return redirect_to root_path
			end

			@payment = @payment.success_pay(response)
			params_response = JSON.parse(response.body)

			@payment.deal.update(status_deal: params_response["status"])

			if @payment.media.nil?
				@payment.update(status_message: "Pago no realizado por algún error...")
			elsif @user.present?
				@user = @payment.user
			end

			redirect_to payment_receipt_path(id: @payment), status: 303
		else
			flash[:error] = "Error en la transacción"
			redirect_to webpay_error_path
		end
	end

	def show
		@payment = Payment.find(params[:id])
	end

	def pay_aproved
		@payment = Payment.find(params[:id])
	end

	def create_checkout(payment)
		# Example items data
		items_data = [
			{
				title: "Producto A",
				description: "Descripción del Producto A",
				quantity: 1,
				unit_price: 100.00
			}
		]

		preference = MercadoPagoService.create_payment_preference(payment)

		if preference
			# Redirect the user to Mercado Pago's checkout page
			# The 'init_point' is the URL for the checkout
			redirect_to deal_path(@payment.deal), status: 200
		else
			flash[:error] = "Error al crear la preferencia de pago con Mercado Pago."
			redirect_to root_path
		end
	end

	def receipt
		@payment = Payment.find(params[:id])
	end

	def success
		payment_id = params[:collection_id] || params[:payment_id]

		if payment_id.present?
			response = MercadoPagoService.get_payment_details(payment_id)
			token = params[:preference_id]
			@payment = Payment.where(token: token).lock(true).take

			if @payment.nil?
				flash[:error] = "No se encontró el pago asociado"
				return redirect_to root_path
			end

			@payment = @payment.success_mp_pay(response)

			redirect_to payment_receipt_path(id: @payment)
		else
			flash[:error] = "ID de pago no encontrado."
			render plain: "ID de pago no encontrado."
		end
	end

	def pending
		# Handle pending payments
		flash[:notice] = "Tu pago está pendiente."
		render plain: "Pago pendiente."
	end

	def failure
		# Handle failed payments
		flash[:alert] = "Tu pago ha fallado."
		render plain: "Pago fallido."
	end

end
