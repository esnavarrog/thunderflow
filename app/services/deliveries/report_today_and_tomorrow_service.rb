class Deliveries::ReportTodayAndTomorrowService < ApplicationService
  def self.execute(user)
    if user.admin?
      deliveries_today = Delivery.where(date_start: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
      deliveries_tomorrow = Delivery.where(date_start: Time.zone.now.tomorrow.beginning_of_day..Time.zone.now.tomorrow.end_of_day)
    end

    if user.client?
      deliveries_today = user.deliveries_access.where(date_start: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
      deliveries_tomorrow = user.deliveries_access.where(date_start: Time.zone.now.tomorrow.beginning_of_day..Time.zone.now.tomorrow.end_of_day)
    end

    if user.delivery?
      deliveries_today = Delivery.where(user_asign_id: user.id, date_start: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
      deliveries_tomorrow = Delivery.where(user_asign_id: user.id, date_start: Time.zone.now.tomorrow.beginning_of_day..Time.zone.now.tomorrow.end_of_day)
    end

    return deliveries_today, deliveries_tomorrow
  end
end

