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
    # Flow envía los parámetros como un POST
    token = params[:token]

    # 1. Validar que el token exista
    return head :bad_request unless token.present?

    # 2. Obtener el estado real desde Flow
    response = Flow.success_flow(params)

    # 3. Procesar la respuesta
    if response&.code == 200
      payment = Payment.where(token: token).lock(true).take

      # Solo procesamos si encontramos el pago y si NO ha sido pagado previamente
      # Esto evita procesar dos veces la misma notificación (idempotencia)
      if payment.present? && !payment.payed?
        payment.success_pay(response) # Usamos tu método existente para actualizar el pago
      end

      # 4. Respondemos a Flow que recibimos la notificación correctamente
      head :ok
    else
      # Si no pudimos obtener el estado de Flow, respondemos un error
      # Flow podría reintentar la notificación más tarde.
      head :unprocessable_entity
    end
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
    token = params['token']
    @payment = Payment.find_by(token: token)

    if @payment.nil?
      flash[:error] = "No se encontró la transacción asociada. Por favor, contacte a soporte."
      return redirect_to root_path
    end

    # La lógica de redirección se mantiene, pero ya no actualiza el pago aquí.
    # Simplemente consulta el estado actual del @payment que debería haber sido
    # actualizado por pay_success.
    case @payment.status.to_sym
    when :payed
      # El pago ya fue confirmado por pay_success, redirigimos al recibo.
      redirect_to payment_receipt_path(id: @payment), status: 303, allow_other_host: true
    when :pending
      flash[:notice] = "El pago está pendiente de confirmación. Te notificaremos cuando se complete."
      redirect_to payment_pending_path(id: @payment)
    when :rejected
      flash[:error] = "El pago ha sido rechazado."
      redirect_to payment_rejected_path(id: @payment)
    when :canceled
      flash[:error] = "El pago ha sido anulado."
      redirect_to payment_cancelled_path(id: @payment)
    else
      # Si el estado es 'nothing' o desconocido, es bueno volver a consultar a Flow
      # por si la notificación asíncrona aún no ha llegado.
      response = Flow.success_flow(params)
      if response&.code == 200
        @payment.success_pay(response) # Actualizamos por si acaso
        # Y re-evaluamos el caso basado en el nuevo estado
        return redirect_based_on_status(@payment)
      end
      flash[:error] = "El estado del pago es desconocido. Por favor, contacte a soporte."
      redirect_to root_path
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
		@payment = Payment.find(params[:id])
		@user = @payment.user
	end

	def rejected
		@payment = Payment.find(params[:id])
		@user = @payment.user
	end

	def cancelled
		@payment = Payment.find(params[:id])
		@user = @payment.user
	end

	def error
		@payment = Payment.find(params[:id])
		@user = @payment.user
  end

  private

  def redirect_based_on_status(payment)
    case payment.status.to_sym
    when :payed
      redirect_to payment_receipt_path(id: payment), status: 303, allow_other_host: true
    when :pending
      redirect_to payment_pending_path(id: payment)
    when :rejected
      redirect_to payment_rejected_path(id: payment)
    when :canceled
      redirect_to payment_cancelled_path(id: payment)
    else
      redirect_to root_path
    end
  end

end
