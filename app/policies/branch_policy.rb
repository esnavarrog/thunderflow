class BranchPolicy < ApplicationPolicy
  def index?
    (user.client? && user.companies.present?) || user.admin?
  end

  def new?
      true
  end

  def edit?
    record.company.owner == user|| record.company.users.include?(user) || user.admin?
  end

  def create?
      true
  end

  def update?
      edit?
  end

  def show?
    record.company.users.include?(user) || record.company.owner == user || user.admin?
  end
end
