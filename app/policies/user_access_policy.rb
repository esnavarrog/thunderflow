class UserAccessPolicy < ApplicationPolicy
    
    def destroy?
        record.company.owner == user || user.admin?
    end

end