class BalancesAPI < Grape::API

  resource :balances do

    route_param :slug_id do
      params do
        optional :date, type: Date, default: -> { Date.today }
      end
      get do
        @house = House.find_by(slug_id: params[:slug_id])
        # return 404 if !@house.v2?
        Balance.new(@house, declared_params[:date]).tap do |balance|
          authorize balance, :show?
        end
      end

      params do
        optional :notify, type: Boolean, default: true
      end
      post do
        @house = House.find_by(slug_id: params[:slug_id])
        # return 404 if !@house.v2?
        Balance.new(@house, Date.today).tap do |balance|
          authorize balance, :update?
          balance.users.each do |item|
            BalanceMailer.pay_email(item[0], item[1]).deliver if declared_params[:notify]
            App.stripe do
              # idempotency_key: safely retrying requests without accidentally performing the same operation twice.
              Stripe::InvoiceItem.create({
                customer: item[0].stripe_id,
                amount: item[1] * 100, currency: 'eur',
                description: "Contribution solidaire de #{I18n.l Date.today, format: :month}",
                }, idempotency_key: user_key(item[0]))
            end
             #user
            item[1] #amount
          end
        end
      end
    end
  end

  helpers do
    def user_key user
      "#{Date.today.strftime('%Y-%m')}-#{user.stripe_id}"
    end
  end
end