class WithdrawalReceiptPolicy < ApplicationPolicy

  def index?
    user.admin? or user.client? or user.delivery?
  end

  def new?
    user.admin? or user.delivery?
  end

  def edit?
    new? && record.user == user
  end

  def create?
    new?
  end

  def update?
    edit?
  end

  def show?
    (record.company.owner == user) or record.company.users.include?(user) or user.admin? or (user.delivery? and record.user == user)
  end

  def destroy?
    create?
  end
end
