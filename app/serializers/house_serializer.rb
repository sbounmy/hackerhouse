class HouseSerializer < ActiveModel::Serializer
  attributes  :name, :slug_id, :slack_id,
                     :stripe_access_token, :stripe_id, :stripe_client_id

  def stripe_oauth_url
    "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=#{object.stripe_client_id}&scope=read_write"
  end
  attributes :stripe_oauth_url
end