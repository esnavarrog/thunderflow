class UserPolicy < ApplicationPolicy

    def index?
        backoffice?
    end
    
    def edit?
        user == record || user.admin?
    end

    def show?
        edit?
    end

    def update?
        edit?
    end
end