class House
  include Mongoid::Document

  # HackerHouse name
  field :name, type: String

  # Stripe access token
  field :stripe_access_token, type: String

  # Stripe account id
  field :stripe_acc_id, type: String

  # Slack channel id without #
  # it is an unique id
  field :slack_channel, type: String
end
