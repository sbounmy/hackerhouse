class UsersAPI < Grape::API

  resource :users do

    desc "Create a User"
    params do
      requires :token,                  type: String, desc: "Card token returned from Stripe"
      requires :slug_id,                type: String, desc: "House slug id ex: hq"
      requires :email,                  type: String
      requires :moving_on,              type: Date,   desc: 'Moving date'
    end

    post do
      house = House.find_by(slug_id: declared_params.delete(:slug_id))
      house.users.build(declared_params).tap do |u|
        Stripe.api_key = house.stripe_access_token
        c = Stripe::Customer.create(
          source: declared_params[:token], # obtained from Stripe.js
          email:  declared_params[:email]
        )
        # directly subscribes user
        begin
        Stripe::Subscription.create(
          customer: c.id,
          plan: "basic_monthly",
          application_fee_percent: 20,
          trial_end: declared_params[:moving_on].to_time.to_i
        )
        rescue Exception => e
          c.delete #rollbacks customer creation if any issue and raise
         raise
        end

        u.plan = 'basic_monthly' #force by default
        u.stripe_id = c.id
        u.password = "#{u.email.split('@')[0]}42" # generate default password from email: stephane@hackerhouse.paris -> stephane42
        u.save!
      end
    end

    desc "Updates an User"
    params do
      optional :avatar_url,             type: String, desc: "Avatar url"
      optional :bio_title,              type: String, desc: "Bio Title"
    end
    put ':id' do
      User.find(params[:id]).tap do |user|
        authorize user, :update?
        user.update_attributes! declared_params
      end
    end

    desc "List Users"
    params do
      optional :q, type: Hash
    end
    get do
      User.search(declared_params[:q])
    end
  end

end
