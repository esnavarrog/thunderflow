class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.present? && current_user.client?
      @companies = current_user.companies
      @branches = current_company&.branches
      @deliveries = current_company&.deliveries&.deliveries_not_payed
    elsif current_user.present? && current_user.delivery?
      options = params
      options = options.merge({ order: 'date_start', status: :asigned })
      options = options.merge({ user_asign_id: current_user.id, no_limit: true }) if current_user.delivery?
      @deliveries = Delivery.fetch(options)
    else
      options = params
      options = options.merge({ order: 'date_start', status: :preparing })
      @deliveries = Delivery.fetch(options)
    end

    @dealers = User.where(role: :delivery)
                   .joins('INNER JOIN deliveries ON users.id = deliveries.user_asign_id')
                   .where(deliveries: { status: :asigned })
                   .group('users.id')
                   .order('COUNT(deliveries.id) DESC')
    @dealers_for_deliver = User.where(role: :delivery)
                               .joins('INNER JOIN deliveries ON users.id = deliveries.user_asign_id')
                               .where.not(deliveries: { status: %i[delivered returned rejected nothing] })
                               .group('users.id')
                               .order('COUNT(deliveries.id) DESC')
  end

  def metrics
    year = params[:year] || 2025
    month = params[:month] || Time.now.month
    @date = Time.parse("01-#{month}-#{year}")
    range = @date.beginning_of_month..@date.end_of_month
    @metrics = Delivery.where(date_start: range)
  end

  def export_deliveries_by_month_and_company
    year = params[:year] || 2025
    range = Time.parse("01-01-#{year}").beginning_of_year..Time.parse("31-12-#{year}").end_of_year

    # Traer los deliveries agrupados por empresa y mes
    deliveries = Delivery.where(date_start: range)
                         .joins(:company)
                         .group("companies.name", "EXTRACT(MONTH FROM date_start)")
                         .count

    # Obtener todas las empresas con deliveries en el rango
    companies = deliveries.keys.map { |k| k[0] }.uniq.sort
    # Nombres de los meses en español
    meses = I18n.t('date.month_names').compact

    # Normalizar las claves del hash deliveries para que el mes sea integer
    normalized_deliveries = {}
    deliveries.each do |(company, mes), count|
      normalized_deliveries[[company, mes.to_i]] = count
    end

    # Construir la matriz de datos para el Excel
    @excel_data = companies.map do |company|
      row = [company]
      (1..12).each do |mes|
        row << (normalized_deliveries[[company, mes]] || 0)
      end
      row
    end
    @meses = meses
    @year = year

    respond_to do |format|
      format.xlsx do
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=Solicitudes por mes #{@year}.xlsx"
      end
      format.html { redirect_to welcome_index_path, alert: "Formato no soportado. Por favor, usa el botón de exportar." }
    end
  end


  def get_pending_deliveries
    @deliveries = current_company&.deliveries&.deliveries_not_payed
  end

  def charts_welcome
    deliveries = current_user.admin? ? Delivery : current_user.deliveries_access
    case params[:chart_date]
    when 'mensual'
      @deliveries_chart = deliveries.where(status: :delivered).group_by_day(:date_start,
                                                                            range: 4.weeks.ago..Time.now, expand_range: true).count
    when 'semanal'
      @deliveries_chart = deliveries.where(status: :delivered).group_by_day(:date_start,
                                                                            range: 7.days.ago..Time.now, expand_range: true).count
    else
      @deliveries_chart = deliveries.where(status: :delivered).group_by_month(:date_start,
                                                                              last: 12).count.transform_keys do |date|
        I18n.l(date, format: '%b').titleize
      end
    end
    # if current_user.client?
    #     case params[:chart_date]
    #     when 'mensual'
    #         @deliveries_price = deliveries.where(status: :delivered).where.not(price: [nil, "", "No tenemos servicio para esta distancia"]).group_by_day(:date_start, range: 4.weeks.ago..Time.now, expand_range: true).sum("price::integer")
    #     when 'semanal'
    #         @deliveries_price = deliveries.where(status: :delivered).where.not(price: [nil, "", "No tenemos servicio para esta distancia"]).group_by_day(:date_start, range: 7.days.ago..Time.now, expand_range: true).sum("price::integer")
    #     else
    #         @deliveries_price = deliveries.where(status: :delivered).where.not(price: [nil, "", "No tenemos servicio para esta distancia"]).group_by_month(:date_start, last: 12).sum("price::integer").transform_keys { |date| I18n.l(date, format: '%b').titleize }
    #     end
    # end
    return unless current_user.admin?

    @clients_chart = Company.group_by_month(:created_at, last: 12).count.transform_keys do |date|
      I18n.l(date, format: '%b').titleize
    end
  end

  def charts_welcome_client
    # use for include a chart for clients, with deliveires for month
  end

  def count_deliveries_asign_daily
    @dealers = User.where(role: :delivered)
  end

  def report_form; end

  def report_for_pay
    options = params
    options = options.merge({ company_id: params[:company_id] }) if params[:company_id].present?
    options = options.merge({ order: 'date_start', no_limit: true })
    options = options.merge({ status: params[:status] }) if !current_user.delivery? && params[:status].present?
    title = if params[:date_start].present? && params[:date_end].present?
              "Solicitudes de #{params[:date_start]} al #{params[:date_end]}"
            elsif params[:date_start].present? && !params[:date_end].present?
              "Solicitudes de #{params[:date_start]}"
            else
              "Solicitudes a la fecha #{Time.zone.now.strftime('%d-%m-%Y %H:%M')}"
            end
    if current_user.present? && current_user.delivery?
      options = options.merge({ user_asign_id: current_user.id,
                                status: :asigned })
    end
    respond_to do |format|
      format.xlsx do
        @deliveries = Delivery.fetch(options)
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=#{title}.xlsx"
      end
    end
  end
end
