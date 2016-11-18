class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :token, type: String
  field :email, type: String
  field :stripe_id, type: String
  field :plan, type: String
  field :moving_on, type: String

  # Associations
  belongs_to :house, index: true
end
