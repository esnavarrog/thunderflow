class DeliveryPolicy < ApplicationPolicy

    def index?
        user.client? && user.companies.present? || user.delivery? || user.admin?
    end

    def index_api?
        user.admin?
    end

    def new?
        true
    end

    def edit?
        record.branch.company.users.include?(user) || user.admin? || user.delivery?
    end

    def create?
        true
    end

    def update?
        edit?
    end

    def show?
        edit?
    end

    def create_deliveries?
        create?
    end

    def delivery_null_deal?
        update?
    end

end
