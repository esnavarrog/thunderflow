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
				begin
					@payment = Payment.prepare_webpay(@deal, user)
					result = Flow.init_transaction(@payment)
				rescue => e
					p "Error en la transacción #{e}"
				end
        if result && result['token'].present? && result['url'].present?
            token = result['token']
            url   = result['url']
            @payment.update(token:token) if @payment
            # response = Net::HTTP.post_form(URI(url.to_s), token_ws: token.to_s)
            redirect_to url + "?token=" +token
        else
            redirect_to root_path, alert: "Error al procesar el pago. Por favor, inténtelo de nuevo más tarde."
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

			redirect_to deal_path(@payment.deal), status: 303
		else
			flash[:error] = "Error en la transacción"
			redirect_to webpay_error_path
		end
	rescue StandardError => e
		Rails.logger.error("Error en success_final: #{e.message}")
		flash[:error] = "Ocurrió un error inesperado"
		redirect_to webpay_error_path
	end

	def show
		@payment = Payment.find(params[:id])
	end

	def pay_aproved
		@payment = Payment.find(params[:id])
	end

end
