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
  field :check_in, type: Date
  field :check_out, type: Date
  field :password_digest, type: String
  field :stripe_id, type: String
  field :token, type: String
  field :bio_title, type: String
  field :bio_url,   type: String

  # Stripe id
  field :stripe_id, type: String
  field :stripe_subscription_ids, type: Array, default: []

  # Indexes
  index active: 1

  # Associations
  belongs_to :house, index: true

  # Bcrypt
  has_secure_password

  # Scope
  scope :staying_on, ->(date, house) { where(house_id: house.id, :check_out.gt => date.beginning_of_month) }

  # Validations
  validate :should_stay_at_least_1_month

  def should_stay_at_least_1_month
    if check_out < check_in + 1.month 
      errors.add(:check_out, "should not be less than #{check_in + 1.month}") 
    end
  end
end
