FactoryGirl.define do

  factory :user do
    sequence(:email) { |n| "#{firstname.parameterize(separator: '_')}-#{n}@42.student.fr" }
    firstname 'Paul'
    lastname 'Amicel'
    password 'tiramisu42'
    check_in '2016-12-20'
    check_out '2017-02-20'
    avatar_url 'http://avatar.slack.com/paul.jpg'
    house

    transient do
      stripe false
    end

    # Create customer on stripe and set it's stripe_id
    # Use only when you need to query on Stripe API
    # Example : create(:user, stripe: true)
    before(:create) do |user, evaluator|
      if evaluator.stripe
        App.stripe do
          c = Stripe::Customer.create(email: evaluator.email, card: StripeMock.create_test_helper.generate_card_token)
          evaluator.stripe_id = c.id
        end
      end
    end
  end

end
