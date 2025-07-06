# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def client?
    user.client?
  end

  def delivery?
    user.delivery?
  end

  def backoffice?
    user.admin? && !user.role.nil?
  end

  def staff?
    backoffice? or user.delivery?
  end

  def administration?
    user.admin? || user.client? || user.delivery?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end
