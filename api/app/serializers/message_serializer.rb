class MessageSerializer < ActiveModel::Serializer
  attributes :body, :check_in, :check_out, :status, :created_at
  belongs_to :user
end