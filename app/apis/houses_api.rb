class HousesAPI < Grape::API

  resource :houses do
    route_param :slug_id do

      desc "Get a house"
      get do
        House.find_by(slug_id: params[:slug_id])
      end

    end

  end

end
