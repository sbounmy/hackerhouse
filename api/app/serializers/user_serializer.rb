class UserSerializer < ActiveModel::Serializer
  attributes  :id, :firstname, :lastname, :avatar_url, :bio_title, :bio_url
end