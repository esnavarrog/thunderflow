class CompanyPolicy < ApplicationPolicy

    def index?
        user.admin? || user.client?
    end

    def new?
        true
    end

    def edit?
        user.admin? || user.client? && record.owner == user
    end

    def create?
        true
    end

    def update?
        edit?
    end

    def show?
        record.users.include?(user) || record.owner == user || user.admin?
    end

end
