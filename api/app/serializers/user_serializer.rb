class UserSerializer < ActiveModel::Serializer
  attributes  :id, :firstname, :lastname, :avatar_url, :bio_title, :bio_url,
              :check_in, :check_out

  attribute :email, if: :current_user?

  def current_user?
    scope.current_user.id == object.id
  end
end