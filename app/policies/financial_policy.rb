class FinancialPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end