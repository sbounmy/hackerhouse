class TransfersAPI < Grape::API
  helpers do
    def house
      @house ||= House.find_by(slug_id: params[:slug_id])
    end

    def amount
      return (declared_params[:amount] * 100).to_i if declared_params[:amount]

      (house.amount * ( 1 - House::SERVICE_FEE) * 100).ceil
    end
  end
  resource :transfers do

    route_param :slug_id do

      # Should move this to transfer.rb
      desc "Create a transfer"
      params do
        optional :amount, type: Float, desc: "Net amount in euros to transfer to Owner"
      end
      post do
        name = Date.today.strftime("Loyer-%Y-%m")
        authorize Transfer, :create?
        App.stripe do
          error!("Already paid out ! #{house.stripe_id}##{name}", 422) if Stripe::Transfer.list(limit: 10, transfer_group: name, destination: house.stripe_id).to_a.size > 0
        end
        error!("Amount is too high, cant be higher than house amount : #{house.amount}") if declared_params[:amount] && declared_params[:amount] > house.amount
        # need to do this out of App.stripe otherwise it resets its scope value
        metadata = {}
        house.plans.each do |plan|
          metadata[plan.id] = house.amount_for(plan.id) if plan.id != 'fee_monthly'
        end
        App.stripe do
          Stripe::Transfer.create(
            amount: amount,
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
