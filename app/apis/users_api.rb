class UsersAPI < Grape::API

  resource :users do

    desc "Create a User"
    params do
      requires :token,                  type: String, desc: "Card token returned from Stripe"
      requires :stripe_publishable_key, type: String
      requires :email,                  type: String
      requires :moving_on,              type: Date,   desc: 'Moving date'
    end

    # refactor this ! this api call should not be idempotent
    post do
      house = House.find_by(stripe_publishable_key: declared_params[:stripe_publishable_key])
      user = house.users.where(email: declared_params[:email]).first ||  house.users.build(declared_params.except(:stripe_publishable_key))
      user.tap do |u|
        Stripe.api_key = house.stripe_access_token

        c = Stripe::Customer.create(
          source: declared_params[:token], # obtained from Stripe.js
          email:  declared_params[:email]
        ) if u.stripe_id.nil?

        u.plan = 'basic_monthly' #force by default
        u.stripe_id ||= c.id
        u.save!

        # directly subscribes user
        # this should move to a separate api call
        Stripe::Subscription.create(
          customer: u.stripe_id,
          plan: "basic_monthly",
          application_fee_percent: 20,
          trial_end: declared_params[:moving_on].to_time.to_i
        )
      end
    end

  end

end
