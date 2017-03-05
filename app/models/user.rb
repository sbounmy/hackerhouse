class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  # Fields
  field :admin, type: Boolean, default: false
  field :token, type: String
  field :email, type: String
  field :stripe_id, type: String
  field :plan, type: String
  field :moving_on, type: String
  field :avatar_url, type: String
  field :password_digest, type: String
  # Associations
  belongs_to :house, index: true

  # Bcrypt
  has_secure_password
end
