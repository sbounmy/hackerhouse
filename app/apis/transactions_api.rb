class TransactionsAPI < Grape::API

  resource :houses do
    route_param :slug_id do

      resource :transactions do

        desc "Create a Transaction"
        params do
          requires :transaction, type: Hash do
            requires :token, type: String, desc: "Card token returned from Stripe"
          end
        end
        post do
          house = House.where(slug_id: params[:slug_id]).first
          house.transactions.build(declared_params[:transaction]).tap &:save!
        end

      end

    end

  end

end
