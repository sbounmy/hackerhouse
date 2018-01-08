class BalanceSerializer < ActiveModel::Serializer
  attributes :date
  belongs_to :house
  has_many :users
end