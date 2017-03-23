class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword
  include Concerns::MongoidQuery

  # Fields
  field :active, type: Boolean, default: false
  field :admin, type: Boolean, default: false
  field :avatar_url, type: String
  field :firstname, type: String
  field :lastname, type: String
  field :email, type: String
  field :moving_on, type: String
  field :password_digest, type: String
  field :plan, type: String
  field :stripe_id, type: String
  field :token, type: String
  field :job_title, type: String

  # Indexes
  index active: 1

  # Associations
  belongs_to :house, index: true

  # Bcrypt
  has_secure_password
end
