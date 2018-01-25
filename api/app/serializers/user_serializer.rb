class UserSerializer < ActiveModel::Serializer
  attributes  :id, :firstname, :lastname, :avatar_url, :bio_title, :bio_url,
              :check_in, :check_out, :active, :admin, :house_slug_id

  attribute :email, if: :current_user?

  def current_user?
    scope.current_user.id == object.id
  end

  # overkill but clean for API call
  def house_slug_id
    object.house.try(:slug_id)
  end
end