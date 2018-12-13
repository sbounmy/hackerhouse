class TokenSerializer < ActiveModel::Serializer
  attributes  :email, :firstname, :lastname, :remote_avatar_url, :bio_title, :bio_url, :location, :token
end