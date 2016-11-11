class House
  include Mongoid::Document

  # HackerHouse name
  field :name, type: String

  # Description text
  field :description, type: String

  # Stripe access token
  field :stripe_access_token, type: String

  # Stripe attributes
  # - stripe acc_id
  field :stripe_id, type: String
  # - stripe connect client_id ca_xxxx
  field :stripe_client_id, type: String

  # it is an unique id
  # Must match a slack channel ID without #
  field :slug_id, type: String

  has_many :transactions

  def slack_id
    "##{slug_id}"
  end
end
