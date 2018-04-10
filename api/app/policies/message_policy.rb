class MessagePolicy < ApplicationPolicy
  def show?
    user.admin? || user.house_id == record.house.id
  end

  def create?
    user.admin? || (user.id && user.id == record.user_id)
  end

  # Can like if with admin token
  # or user belongs to house and still staying
  def like?
    user.admin? || user.active_on?(record.house)
  end
end