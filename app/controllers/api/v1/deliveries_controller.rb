class Api::V1::DeliveriesController < ApiController
    skip_before_action :verify_authenticity_token
    before_action :set_delivery, only: [:show, :destroy]
    before_action :authorize_delivery_action, only: [:destroy]
    before_action :authenticate_request, only: [:index, :show, :create, :update, :destroy]

    def index
        unless @current_user&.delivery?
            render json: { errors: ['No estás autorizado para acceder a esta información.'] }, status: :unauthorized
            return
        end

        @deliveries = Delivery.assigned_and_active_for_courier(@current_user.id)
        render 'api/v1/deliveries/index'
    end

    def show
        render json: @delivery.as_json(
          methods: [:hour_delivery, :hour_retired, :name_user_asign, :klass_statuses],
          include: {
            branch: { only: [:id, :name, :address_street, :address_number, :commune, :latitude, :longitude] },
            company: { only: [:id, :name, :fantasy_name] },
            statuses: { only: [:status, :observation, :created_at, :image] } # Incluye el historial de estados
          }
        ), status: :ok
    end

    def create
        branch_id = delivery_params[:branch_id]
        @branch = Branch.find_by(id: branch_id)

        unless @branch
            render json: { errors: ['La sucursal especificada no fue encontrada.'] }, status: :unprocessable_entity
            return
        end

        unless authorized_to_create_for_branch?(@branch)
            render json: { message: 'No estás autorizado para crear entregas en esta sucursal.' }, status: :unauthorized
            return
        end

        delivery = build_delivery_from_params

        delivery.branch = @branch
        delivery.company = @branch.company
        delivery.status = :preparing # Asigna el estado inicial adecuado, por ejemplo, 'preparing'

        if delivery.save
            DeliveryMailer.new_delivery(delivery.company.owner.id, delivery.id).deliver_later
            response = {
              respuesta: 1,
              message: 'Solicitud creada exitosamente',
              idDelivery: delivery.id,
              order_number: delivery.order_number
            }
            render json: response, status: :created
        else
            puts 'Errores de entrega:'
            puts delivery.errors.full_messages
            render json: { errors: delivery.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update
        delivery = Delivery.find(params[:id])
        unless authorized_for_delivery?(delivery)
            render json: { message: 'No estás autorizado para realizar esta acción en esta solicitud.' }, status: :unauthorized
            return
        end

        status = Status.new(status_params)
        status.delivery = delivery
        status.user_id = @current_user.id if @current_user.present?

        if status.save
            render json: delivery, status: :ok
        else
            render json: { errors: status.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        if @delivery.destroy
            render json: { respuesta: 1, message: 'Solicitud eliminada correctamente', idDelivery: @delivery.id }, status: :ok
        else
            render json: { errors: @delivery.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def set_delivery
        @delivery = Delivery.find_by(id: params[:id])
        p 'Delivery encontrado:'
        p @delivery.inspect
        unless @delivery
            render json: { message: 'Solicitud no encontrada.' }, status: :not_found
            return
        end
    end

    def authorize_delivery_action
        unless authorized_for_delivery?(@delivery)
            render json: { message: 'No estás autorizado para realizar esta acción en esta solicitud.' }, status: :unauthorized
            return
        end
    end

    def authorized_for_delivery?(delivery)
        return delivery.user_asign_id == @current_user.id
    end

    def authorized_to_create_for_branch?(branch)
        return false # Por ahora, mantenemos que los repartidores no pueden crear entregas.
    end

    def build_delivery_from_params
        delivery = nil
        if request.headers["origin"] == 'woocommerce'
            woocommerce_params = Woocommerce::NormalizedService.execute(request.body.read)
            delivery = Delivery.new(woocommerce_params)
        else
            delivery = Delivery.new(delivery_params)
            delivery.address_concat = "#{delivery_params[:address_street]} #{delivery_params[:address_number]}, #{delivery_params[:commune]}, Chile"
            delivery.complete_name = "#{delivery_params[:contact_name]} #{delivery_params[:contact_lastname]}"
            delivery.phone_number = delivery_params[:phone_number]&.delete(" ")&.split("")&.last(9)&.join("")
        end
        delivery
    end

    def delivery_params
        params.require(:delivery).permit(
          :weight, :height, :width, :depth, :date_start, :commune, :reference,
          :phone_number, :contact_name, :contact_lastname, :email, :rut,
          :time_open, :time_close, :time_deliver_open, :time_deliver_close,
          :address_concat, :address_street, :address_number, :type_deliver,
          :complete_name, :description, :longitude, :latitude, :branch_id
        )
    end

    def status_params
        params.require(:delivery).permit(
          :image, :observation, :status, :receiver_phone, :receiver_rut, :receiver_name, :description
        )
    end
end