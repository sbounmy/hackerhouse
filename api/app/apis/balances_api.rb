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
          BalanceSynchronizer.with(balance: balance).create(:stripe, :mailer)
        end
      end
    end
  end
end