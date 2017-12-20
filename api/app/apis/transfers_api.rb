class TransfersAPI < Grape::API

  resource :transfers do

    route_param :slug_id do

      desc "Create a transfer"
      post do
        house = House.find_by(slug_id: params[:slug_id])
        name = Date.today.strftime("Loyer-%Y-%m")
        authorize Transfer, :create?
        App.stripe do
          error!("Already paid out ! #{house.stripe_id}##{name}", 422) if Stripe::Transfer.list(limit: 10, transfer_group: name, destination: house.stripe_id).to_a.size > 0
        end
        # need to do this out of App.stripe otherwise it resets its scope value
        metadata = {}
        house.plans.each do |plan|
          metadata[plan.id] = house.amount_for(plan.id) if plan.id != 'fee_monthly'
        end
        App.stripe do
          Stripe::Transfer.create(
            amount: (house.amount * ( 1 - House::OWNER_SERVICE_FEE) * 100).ceil,
            currency: "eur",
            destination: house.stripe_id,
            transfer_group: name,
            metadata: metadata
          )
        end
      end

    end

  end

end
