FactoryGirl.define do

  factory :house do
    name 'Canal Street'

    description 'The first and original HackerHouse'
    slug_id 'hq'
    stripe_access_token "very-secret-token"
    stripe_id "stripe-acc-id"
    stripe_client_id "ca_stripe-client-id"
  end
end
