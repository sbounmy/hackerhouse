FactoryGirl.define do

  factory :user do
    sequence(:email) { |n| "#{firstname.parameterize(separator: '_')}-#{n}@42.student.fr" }
    firstname 'Paul'
    lastname 'Amicel'
    password 'tiramisu42'
    check_in '2016-12-20'
    check_out '2017-02-20'
    remote_avatar_url 'https://upload.wikimedia.org/wikipedia/commons/5/51/Google.png'
    phone_number '0612345678'
    house
    bio_url 'https://linkedin.com/in/blabla'
    transient do
      stripe false
      intercom false
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
    before(:create) do |user, evaluator|
      if evaluator.intercom
        App.intercom do |client|
          c = client.users.create(user_id: evaluator.id.to_s, email: evaluator.email,
            custom_attributes: {
              check_in: evaluator.check_in,
              check_out: evaluator.check_out,
              phone_number: evaluator.phone_number
            }
          )
          if evaluator.house_id
            c.companies = [ { company_id: evaluator.house_id.to_s, name: "hh:#{evaluator.house.slug_id}" }]
          end
          client.users.save(c)
        end
      end
    end

  end

end
