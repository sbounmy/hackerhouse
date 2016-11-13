class UsersAPI < Grape::API

  resource :users do

    desc "Create a User"
    params do
      requires :token,                  type: String, desc: "Card token returned from Stripe"
      requires :stripe_publishable_key, type: String
      requires :email,                  type: String
      requires :moving_on,              type: Date,   desc: 'Moving date'
    end

    post do
      house = House.find_by(stripe_publishable_key: declared_params[:stripe_publishable_key])
      house.users.build(declared_params.except(:stripe_publishable_key)).tap do |u|
        Stripe.api_key = house.stripe_access_token

        c = Stripe::Customer.create(
          source: declared_params[:token], # obtained from Stripe.js
          email: declared_params[:email]
        )

        u.plan = 'basic_monthly' #force by default
        u.stripe_id = c.id
        u.save!

        # directly subscribe user
        Stripe::Subscription.create(
          customer: c.id,
          plan: "basic_monthly",
          application_fee_percent: 20,
          trial_end: declared_params[:moving_on].to_time.to_i
        )
      end
    end

  end

end
