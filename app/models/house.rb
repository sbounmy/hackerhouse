# 1 house = 1 stripe account
class House
  include Mongoid::Document
  include Mongoid::Timestamps

  # HackerHouse name
  field :name, type: String

  # Description text
  field :description, type: String

  # Stripe access token
  field :stripe_access_token, type: String

  # Stripe attributes
  # - stripe acc_id
  field :stripe_id, type: String

  # it is an unique id
  # Must match a slack channel ID without #
  field :slug_id, type: String

  has_many :transactions

  # Validations
  validates :slug_id, uniqueness: true, presence: true
  validates :stripe_id, uniqueness: true, presence: true
  validates :stripe_access_token, presence: true

  def slack_id
    "##{slug_id}"
  end
end
