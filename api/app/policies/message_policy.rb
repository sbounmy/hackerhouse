class MessagePolicy < ApplicationPolicy
  def show?
    user.admin? || user.house_id == record.house.id
  end

  def create?
    user.admin? || (user.id && user.id == record.user_id)
  end
end