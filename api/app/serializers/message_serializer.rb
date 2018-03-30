class MessageSerializer < ActiveModel::Serializer
  attributes :body, :check_in, :check_out, :status
  belongs_to :user
end