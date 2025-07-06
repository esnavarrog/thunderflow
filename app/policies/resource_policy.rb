class ResourcePolicy < ApplicationPolicy
    def index?
        user.admin?
    end

    def new?
        true
    end

    def edit?
        record.company.owner == user || user.admin?
    end

    def create?
        true
    end

    def destroy?
        user.admin?
    end

    def update?
        edit?
    end

    def show?
        edit?
    end
end