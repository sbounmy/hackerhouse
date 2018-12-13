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
      user = User.where(email: declared_params[:email]).first || house.users.build
      user.tap do |u|
        u.house = house
        u.attributes = declared_params
        house.stripe do
          @c = Stripe::Customer.create(
            source: declared_params[:token], # obtained from Stripe.js
            email:  declared_params[:email]
          )
        end
        begin
          if house.v2?
            @sub = SharedSubscription.new(house, {
              customer: @c.id,
              check_in: declared_params[:check_in],
              check_out: declared_params[:check_out] }
            )
            @sub.save
          else #v1 remove
            house.stripe { @sub = Stripe::Subscription.create(customer: @c.id,
              items: house.stripe_plan_ids.map { |pid| { plan: pid, quantity: 1} },
              metadata: { account_id: house.stripe_id },
              trial_end: declared_params[:check_in].to_time.to_i,
              application_fee_percent: house.stripe_application_fee_percent) }
          end
        rescue Exception => e
          @c.delete #rollbacks customer creation if any issue and raise
         raise
        end

        u.stripe_id = @c.id
        u.stripe_subscription_ids.push @sub.id
        u.stripe_prorata_id = @sub.prorata_id if house.v2?
        u.password = "#{u.email.split('@')[0]}42" # generate default password from email: stephane@hackerhouse.paris -> stephane42
        u.save!
        UserSynchronizer.with(user: u).create(:intercom)
      end
    end

    desc "Updates an User"
    params do
      optional :remote_avatar_url,      type: String, desc: "Avatar url"
      optional :bio_title,              type: String, desc: "Bio Title"
      optional :bio_url,                type: String, desc: "Linkedin URL"
      optional :check_out,              type: Date,   desc: "Check out Date"
      optional :firstname,              type: String, desc: "Firstname"
      optional :lastname,               type: String, desc: "Lastname"
      optional :phone_number,           type: String, desc: "Phone Number"
    end
    put ':id' do
      User.find(params[:id]).tap do |user|
        authorize user, :update?
        user.update_attributes! declared_params
        UserSynchronizer.with(user: user).update(:stripe, :intercom, :mailer)
      end
    end

    desc "Get an User"
    get ':id' do
      User.find(params[:id])
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
