class HouseSerializer < ActiveModel::Serializer
  attributes  :name, :description, :slug_id, :slack_id,
                     :stripe_publishable_key, :stripe_id

  def stripe_oauth_url
    "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=#{Rails.application.secrets.stripe_client_id}&scope=read_write"
  end
  attributes :stripe_oauth_url
end