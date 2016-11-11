class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :token, type: String

  # Associations
  belongs_to :house, index: true
end
