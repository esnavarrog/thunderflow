class DealPolicy < ApplicationPolicy
    def index?
        user.admin? || (user.client? && user.companies.present?)
    end

    def new?
        true
    end

    def edit?
        record.company.users.include?(user) ||
          user.admin? &&
            !record.payed?
    end

    def create?
        edit?
        # por ahora, luego que se pueda crear cuando se genere una solicitud o seleccione para pagar
    end

    def update_archives?
        record.company.users.include?(user) || user.admin?
    end

    def update?
        edit?
    end

    def destroy?
        create?
    end

    def show?
        edit?
    end
end