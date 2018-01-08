class TransferPolicy < ApplicationPolicy
  def create?
    user.admin?
  end
end