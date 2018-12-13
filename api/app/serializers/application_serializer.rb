class ApplicationSerializer < ActiveModel::Serializer
  def current_user?
    !!scope.current_user.id
  end

  def current_user
    scope.current_user
  end

  def admin?
     current_user && current_user.admin?
  end

  def active?
    current_user &&
    current_user.active_on?(current_user.house)
  end

  def admin_or_active?
    admin? || active?
  end
end
