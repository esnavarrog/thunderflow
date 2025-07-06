class ArchivePolicy < ApplicationPolicy
  def edit?
    user.admin? || record.user == user
  end

  def delete?
    edit?
  end

  def archives_in_deal?
    user.admin || user.client?
  end
end
