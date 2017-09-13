class UsersAPI < Grape::API

  resource :users do

    desc "Create a User"
    params do
      requires :token,                  type: String, desc: "Card token returned from Stripe"
      requires :slug_id,                type: String, desc: "House slug id ex: hq"
      requires :email,                  type: String
      requires :check_in,               type: Date,   desc: 'Check in date'
      requires :check_out,              type: Date,   desc: 'Check out date'      
    end

    post do
      house = House.find_by(slug_id: declared_params.delete(:slug_id))
      house.users.build(declared_params).tap do |u|
        house.stripe do
          c = Stripe::Customer.create(
            source: declared_params[:token], # obtained from Stripe.js
            email:  declared_params[:email]
          )
          # directly subscribes user
          subscription_params = {
            customer: c.id,
            items: house.stripe_plan_ids.map { |pid| { plan: pid, quantity: 1} },
            trial_end: declared_params[:check_in].to_time.to_i,
            metadata: { account_id: house.stripe_id },
            prorate: false }
          subscription_params.merge(application_fee_percent: house.stripe_application_fee_percent) unless house.v2?

          begin
            sub = Stripe::Subscription.create(subscription_params)
          rescue Exception => e
            c.delete #rollbacks customer creation if any issue and raise
           raise
          end

          u.stripe_id = c.id
          u.stripe_subscription_ids.push sub.id
          u.password = "#{u.email.split('@')[0]}42" # generate default password from email: stephane@hackerhouse.paris -> stephane42
          u.save!
        end
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
