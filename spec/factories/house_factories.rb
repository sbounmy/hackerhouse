FactoryGirl.define do

  factory :house do
    name 'Canal Street'

    description 'The first and original HackerHouse'
    slug_id 'hq'
    stripe_access_token "sk_very-secret-token"
    stripe_id "stripe-acc-id"
    stripe_refresh_token "rt_very-secret-token"
    stripe_publishable_key "pk_public-token"
  end
end
