class SourcesAPI < Grape::API

  resource :users do
    route_param :id do

      resource :sources do
        desc "Attach a payment to User"
        params do
          requires :source, type: String, desc: "Token returned from Stripe"
        end
        post do
          App.stripe do
            Stripe::Customer.retrieve(User.find(params[:id]).stripe_id).tap do |c|
              c.sources.create source: declared_params[:source]
            end
          end
        end
      end

    end
  end
end
