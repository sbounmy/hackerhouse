class UserSerializer < ActiveModel::Serializer
  attributes  :id, :firstname, :lastname, :avatar_url, :bio_title, :bio_url,
              :check_in, :check_out, :active, :admin, :house_slug_id, :house_id

  attribute :email, if: :current_user_or_admin?

  def current_user_or_admin?
    (scope.current_user.id == object.id) || scope.current_user.admin?
  end

  # overkill but clean for API call
  def house_slug_id
    object.house.try(:slug_id)
  end
end