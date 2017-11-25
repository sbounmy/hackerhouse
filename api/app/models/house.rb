# 1 house = 1 stripe account
class House
  include Mongoid::Document
  include Mongoid::Timestamps

  scope :v2, -> { where(v2: true) }
  
  # HackerHouse name
  field :name, type: String

  # Description text
  field :description, type: String

  # Stripe tokens
  field :stripe_access_token, type: String
  field :stripe_refresh_token, type: String
  field :stripe_publishable_key, type: String

  # Stripe attributes
  # - stripe acc_id
  field :stripe_id, type: String
  # - application_fee
  field :stripe_application_fee_percent, type: Float, default: 20

  # - stripe_plan_ids
  field :stripe_plan_ids, type: Array, default: ["rent_monthly", "fee_monthly", 'utilities_monthly']
  field :stripe_coupon_ids, type: Array, default: []
  field :min_stay_in_days, type: Integer, default: 28*2 #2 months default
  field :v2, type: Boolean, default: true
  # rent amount in cents
  field :amount, type: Integer, default: 100_00
  field :min_users, type: Integer, default: 1
  
  # it is an unique idwork_monthly
  # Must match a slack channel ID without #
  field :slug_id, type: String

  # Associations
  has_many :users

  # Validations
  validates :slug_id, uniqueness: true, presence: true
  validates :stripe_id, uniqueness: true, presence: true
  validates :stripe_access_token, presence: true

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
      if v2
        Stripe.api_key = Rails.application.secrets.stripe_secret_key
      else
        Stripe.api_key = stripe_access_token
      end
      yield
    rescue Exception => e
      raise e
    ensure
      Stripe.api_key = nil
    end
  end

  # v1
  def price_in_cents
    @price_in_cents ||= plans.sum &:amount
  end

  def rent_on(time)
    @rent ||= Rent.new(self, amount, time, min_users)
  end
end
