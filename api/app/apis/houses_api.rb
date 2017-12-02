class HousesAPI < Grape::API

  resource :houses do

    route_param :slug_id do

      desc "Get a house"
      get do
        House.find_by(slug_id: params[:slug_id])
      end

      get 'pay' do
        @house = House.find_by(slug_id: params[:slug_id])
        # return 404 if !@house.v2?
        puts HouseRent.new(@house, Date.today).users.inspect
        HouseRent.new(@house, Date.today).users.each do |item|
          HouseRentMailer.pay_email(item[0], item[1]).deliver
          App.stripe do
            Stripe::InvoiceItem.create(customer: item[0].stripe_id,
              amount: item[1] * 100, currency: 'eur', description: "Contribution solidaire de #{I18n.l Date.today, format: :month}")
          end
           #user
          item[1] #amount
        end
        @house
      end
    end

    params do
      requires :name,                   type: String, desc: "HackerHouse's name"
      requires :slug_id,                type: String, desc: "Slack channel id"
      requires :stripe_access_token,    type: String
      requires :stripe_refresh_token,   type: String
      requires :stripe_publishable_key, type: String
      requires :stripe_id,              type: String

      optional :description,            type: String, desc: "Description"
    end
    post do
      House.create! declared_params
    end
  end

end
