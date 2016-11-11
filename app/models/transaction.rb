class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :token
end
