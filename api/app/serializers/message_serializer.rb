class MessageSerializer < ActiveModel::Serializer
  attributes :body, :check_in, :check_out, :status, :created_at, :house_id, :like_ids
  belongs_to :user
end