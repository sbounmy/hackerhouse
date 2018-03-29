class MessagePolicy < ApplicationPolicy
  def show?
    user.admin? || user.house_id == record.house.id
  end

  def create?
    user.id && user.id == record.user_id
  end
end