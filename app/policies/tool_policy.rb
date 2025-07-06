class ToolPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
