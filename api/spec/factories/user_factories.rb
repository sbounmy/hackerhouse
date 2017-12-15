FactoryGirl.define do

  factory :user do
    email { "#{firstname.parameterize(separator: '_')}@42.student.fr" }
    firstname 'Paul'
    lastname 'Amicel'
    password 'tiramisu42'
    check_in '2016-12-20'
    check_out '2017-02-20'
    avatar_url 'http://avatar.slack.com/paul.jpg'
    house
    active true

    transient do
      stripe false
    end

    # Create customer on stripe and set it's stripe_id
    # Use only when you need to query on Stripe API
    # Example : create(:user, stripe: true)
    before(:create) do |user, evaluator|
      if evaluator.stripe
        App.stripe do
          c = Stripe::Customer.create(email: evaluator.email)
          evaluator.stripe_id = c.id
        end
      end
    end
  end

end
