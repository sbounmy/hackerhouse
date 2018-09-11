# 1 house = 1 stripe account
class House
  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::MongoidQuery

  # Scopes
  scope :v2, -> { where(v2: true) }

  # Constants
  SERVICE_FEE = 0.12

  # Email text
  field :email, type: String

  # HackerHouse name
  field :name, type: String
  field :door_key, type: String
  field :building_key, type: String
  field :address, type: String
  field :zip_code, type: String
  field :city, type: String

  # Type of property.
  # True : will send/show a subscription contract
  # False : will send/show a residential mix contract
  field :commercial, type: Boolean, default: true

  # Description text
  field :description, type: String

  # Stripe tokens
  field :stripe_access_token, type: String
  field :stripe_refresh_token, type: String
  field :stripe_publishable_key, type: String

  # Google Drive
  field :gdrive_folder_id, type: String

  # Stripe attributes
  # - stripe acc_id
  field :stripe_id, type: String
  # - application_fee
  field :stripe_application_fee_percent, type: Float, default: 20

  # - stripe_plan_ids
  field :stripe_plan_ids, type: Array, default: ["rent_monthly", "utilities_monthly", "cleaning_monthly"]
  field :stripe_coupon_ids, type: Array, default: []
  field :min_stay_in_days, type: Integer, default: 28*2 #2 months default
  field :v2, type: Boolean, default: true
  # rent amount in cents
  # field :amount, type: Integer, default: 100_00

  field :cleaning_monthly, type: Float, default: 500
  field :pantry_monthly, type: Float, default: 300
  field :rent_monthly, type: Float, default: 10000
  field :utilities_monthly, type: Float, default: 100

  field :max_users, type: Integer, default: 8

  # it is an unique idwork_monthly
  # Must match a slack channel ID without #
  field :slug_id, type: String

  # Pantry
  field :pantry_budget, type: Float
  field :pantry_description, type: String
  field :pantry_login, type: String
  field :pantry_name, type: String
  field :pantry_url, type: String
  field :pantry_password, type: String

  # Associations
  has_many :users

  # Validations
  validates :slug_id, uniqueness: true, presence: true
  validates :stripe_id, uniqueness: true, presence: true
  validates :stripe_access_token, presence: true

  def self.queryable_scopes
    []
  end

  def slack_id
    "##{slug_id}"
  end

  # v1
  def plans
    stripe do
      @plans ||= stripe_plan_ids.map do |plan_id|
        Stripe::Plan.retrieve(plan_id)
      end
    end
  end

  def coupons
    stripe do
      @coupons ||= stripe_coupon_ids.map do |coupon_id|
        Stripe::Coupon.retrieve(coupon_id)
      end
    end
  end

  def coupon_to_s
    "Une remise sera appliquée pour " +
    @s ||= coupons.map do |c|
      "#{c.metadata['description']} -#{c.percent_off}%"
    end.join(' ou ')
  end

  def stripe
    begin
      @prev = Stripe.api_key
      if v2
        Stripe.api_key = Rails.application.secrets.stripe_secret_key
      else
        Stripe.api_key = stripe_access_token
      end
      @res = yield
    rescue => e
      raise e
    ensure
      Stripe.api_key = @prev || nil
      @res
    end
  end

  # v1
  def price_in_cents
    @price_in_cents ||= plans.sum &:amount
  end

  def amount_for(name)
    send(name)
  end

  def amount_for_user(name)
    amount_for(name) / max_users
  end

  # Return sum total
  def amount_total_per_user
    subscription_items.inject(0) do |sum, (id, item)|
      sum + item[:quantity]
    end
  end

  # Quantity friendly (ceil value) format to display on /gp/:slug_id
  # Returns : { 'rent_monthly' => { name: 'Location', quantity: 500 },
  #             'pantry_monthly' => { name: 'Garde Manger', quantity: 150 },
  #              ...}
  def subscription_items
    {}.tap do |h|
      plans.each do |plan|
        h[plan.id] = { name: products[plan.product].name, quantity: amount_for_user(plan.id).ceil }
      end
    end
  end

  def product_ids
    plans.map &:product
  end

  def products
    return @products if @products
    data = stripe { Stripe::Product.list(type: 'service', ids: product_ids).data }
    @products ||= Hash[data.map { |item| [item.id, item] } ]
  end

  # Stripe API friendly format
  # Returns : [ { plan: 'rent_monthly', quantity: 500 },
  #             { plan: 'pantry_monthly', quantity: 200},
  #              ...]
  def stripe_items
    subscription_items.map do |id, plan|
      { plan: id, quantity: plan[:quantity] }
    end
  end

  def amount
    stripe_plan_ids.sum do |plan_id|
      amount_for(plan_id)
    end
  end
end
