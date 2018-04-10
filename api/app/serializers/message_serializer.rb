class MessageSerializer < ActiveModel::Serializer
  attributes :id, :body, :check_in, :check_out, :status, :created_at, :house_id, :like_ids, :user_id
  belongs_to :user
end