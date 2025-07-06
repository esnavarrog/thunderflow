class Deliveries::CreateStatusService < ApplicationService
    def self.execute(delivery, options = {}, params = {}, current_user, observation)
        status = options.present? ? Status.new(options) : Status.new
        status.delivery = delivery
        status.user_id = current_user.id
        status.status = delivery.status
        status.observation = observation
        status.save
        status
    end
end
