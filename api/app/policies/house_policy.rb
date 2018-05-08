class HousePolicy < ApplicationPolicy
  def update?
    user.admin?
  end
end