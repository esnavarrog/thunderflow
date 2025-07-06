class WelcomePolicy < ApplicationPolicy

  def index?
    true
  end

  def new?
    true
  end

  def create?
    true
  end

  def update?
    edit?
  end

  def show?
    edit?
  end

  def valid_user?
    return true unless user&.client?

    user&.companies&.any?
  end
end
