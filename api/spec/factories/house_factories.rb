FactoryGirl.define do

  factory :house do
    name 'Canal Street'

    description 'The first and original HackerHouse'
    sequence(:slug_id) {|n| "hq-#{n}" }
    stripe_access_token "sk_very-secret-token"
    sequence(:stripe_id) { |n| "stripe-acc-#{n}" }
    stripe_refresh_token "rt_very-secret-token"
    stripe_publishable_key "pk_public-token"
  end
end
