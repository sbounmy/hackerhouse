class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword
  include Concerns::MongoidQuery

  # Fields
  field :admin, type: Boolean, default: false
  field :avatar_url, type: String
  field :firstname, type: String
  field :lastname, type: String
  field :email, type: String
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

  # Linkedin
  field :linkedin_access_token, type: String

  # Indexes

  # Associations
  belongs_to :house, index: true, optional: true

  # Bcrypt
  has_secure_password

  # Scope
  scope :staying_on, ->(date, house) { where(house_id: house.id, :check_out.gt => date.beginning_of_month, :check_in.lte => date.end_of_month) }
  scope :active, ->(val=1) { where(:check_out.gt => Date.today, :house_id.ne => nil) }
  # hack val=1 to preserve client behavior. it sends a param by default

  def self.queryable_scopes
    [:active]
  end

  # Validations
  validate :should_stay_at_least_1_month

  validates :email, uniqueness: true

  def active
    !!check_out && !check_out.past? && house_id.present?
  end

  def should_stay_at_least_1_month
    return if check_out.nil? || check_in.nil? # now can create account without checkin/checkout
    if check_out < check_in + 1.month
      errors.add(:check_out, "should not be less than #{check_in + 1.month}")
    end
  end

  def check=(dates)
    self.check_in, self.check_out = dates
  end

  def push!(params={})
    App.stripe do
      Stripe::Customer.retrieve(stripe_id).tap do |c|
        c.email = email
        c.metadata[:oid] = id.to_s
        c.metadata[:house] = house.slug_id
        c.metadata[:check_in] = check_in
        c.metadata[:check_out] = check_out
        params.each do |method, value|
          c.send "#{method}=", value
        end
        c.save
      end
    end
  end

  def authenticate_linkedin(tk)
    return false if linkedin_access_token.nil? || tk.nil?
    linkedin_access_token == tk
  end

end
