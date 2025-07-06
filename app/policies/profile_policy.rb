class ProfilePolicy < ApplicationPolicy
    def index?
        user.admin? || user.executive?
    end

    def new?
        true
    end

    def edit?
        user == record || user.admin?
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