class BalancesAPI < Grape::API

  resource :balances do

    # params do
    #   requires :month, type: Integer
    #   requires :year, type: Integer
    # end
    route_param :slug_id do
      get do
        @house = House.find_by(slug_id: params[:slug_id])
        # return 404 if !@house.v2?
        Balance.new(@house, Date.today)
      end

      params do
        optional :notify, type: Boolean, default: true
      end
      post do
        @house = House.find_by(slug_id: params[:slug_id])
        # return 404 if !@house.v2?
        Balance.new(@house, Date.today).tap do |balance|
          balance.users.each do |item|
            BalanceMailer.pay_email(item[0], item[1]).deliver if declared_params[:notify]
            App.stripe do
              Stripe::InvoiceItem.create(customer: item[0].stripe_id,
                amount: item[1] * 100, currency: 'eur', description: "Contribution solidaire de #{I18n.l Date.today, format: :month}")
            end
             #user
            item[1] #amount
          end
        end
      end
    end
  end

end