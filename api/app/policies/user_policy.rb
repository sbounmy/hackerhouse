class UserPolicy < ApplicationPolicy
  def update?
    user.admin? || user.id == record.id
  end
end