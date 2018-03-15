class BalancePolicy < ApplicationPolicy
  def show?
    user.admin? || user.house_id == record.house.id
  end

  def update?
    user.admin?
  end
end