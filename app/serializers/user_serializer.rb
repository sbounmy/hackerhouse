class UserSerializer < ActiveModel::Serializer
  attributes  :id, :firstname, :lastname, :avatar_url
end