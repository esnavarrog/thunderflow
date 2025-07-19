class DriverPositionPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def create?
    user.present?
  end

  def update?
    user.present?
  end

  def destroy?
    user.admin?
  end
end
