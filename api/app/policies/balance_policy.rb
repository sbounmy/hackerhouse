class BalancePolicy < ApplicationPolicy
  def show?
    user.admin?
  end

  def update?
    show?
  end
end