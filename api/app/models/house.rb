# 1 house = 1 stripe account
class House
  include Mongoid::Document
  include Mongoid::Timestamps

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
  # - default price in cents
  field :default_price, type: Integer, default: 52000
  # - stripe plan
  field :plan, type: String, default: "basic_monthly"
  # - stripe_plan_ids
  field :stripe_plan_ids, type: Array, default: ["work_monthly", "sleep_monthly"]
  field :stripe_coupon_ids, type: Array, default: []
  
  # it is an unique id
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
      Stripe.api_key = stripe_access_token
      yield
    rescue Exception => e
      raise e
    ensure
      Stripe.api_key = nil
    end
  end

  def price_in_cents
    @price_in_cents ||= plans.sum &:amount
  end
end
