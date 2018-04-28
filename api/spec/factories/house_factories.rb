FactoryGirl.define do

  factory :house do
    name 'Canal Street'
    sequence(:email) {|n| "test+#{n}@hackerhouse.paris" }

    description 'The first and original HackerHouse'
    sequence(:slug_id) {|n| "hq-#{n}" }
    stripe_access_token "sk_very-secret-token"
    sequence(:stripe_id) { |n| "stripe-acc-#{n}" }
    stripe_refresh_token "rt_very-secret-token"
    stripe_publishable_key "pk_public-token"
    stripe_plan_ids ['rent_monthly', 'utilities_monthly', 'cleaning_monthly']
    utilities_monthly 0
    cleaning_monthly 0
    pantry_monthly 0
    max_users 4

    pantry_login 'pantry@hackerhouse.paris'
    pantry_password 'pantry42'
    pantry_budget 100
    pantry_description 'Livraison bi-mensuel'
    pantry_url 'https://courses-en-ligne.carrefour.fr'

    transient do
      stripe false
    end

    # Create customer on stripe and set it's stripe_id
    # Use only when you need to query on Stripe API
    # Example : create(:user, stripe: true)
    before(:create) do |user, evaluator|
      if evaluator.stripe
        App.stripe do
          c = Stripe::Account.create(email: evaluator.email,
            type: 'custom', country: 'fr') #custom so we can delete it
          evaluator.stripe_id = c.id
        end
      end
    end
  end

end
