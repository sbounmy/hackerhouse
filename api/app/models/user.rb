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
  has_many   :messages

  # Bcrypt
  has_secure_password

  # Scope
  scope :customer, -> { where(admin: false) }
  scope :staying_on, -> (date, house) { where(house_id: house.id, :check_out.gt => date.beginning_of_month, :check_in.lte => date.end_of_month) }
  scope :active, -> (value=true) {
    value.to_s == 'true' ? where(:check_out.gt => Date.today) : where(:check_out.lt => Date.today)
  }
  # hack val=1 to preserve client behavior. it sends a param by default
  scope :upcoming, -> (value=true) {
    value.to_s == 'true' ? where(:check_in.gte => Date.today) : all
  }

  scope :active_or_upcoming, -> {
    today = Date.today
    any_of({ :check_in.gte => today }, { :check_out.gte => today })
  }

  def self.queryable_scopes
    [:active, :upcoming, :active_or_upcoming]
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
        # this will break if someone move to another hackerhouse
        Stripe::Subscription.list(customer: stripe_id).each do |s|
          s.metadata[:house] = house.slug_id
          s.metadata[:check_in] = check_in
          s.metadata[:check_out] = check_out
          s.save
        end
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
