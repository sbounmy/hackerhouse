class HousesAPI < Grape::API

  resource :houses do

    route_param :slug_id do
      desc "Show a house"
      get do
        House.find_by(slug_id: params[:slug_id])
      end

      desc "Update a house"
      params do
        optional :door_key, type: String,     desc: "Door entrance key"
        optional :building_key, type: String, desc: "Building entrance key"
      end
      put do
        House.find_by(slug_id: params[:slug_id]).tap do |house|
          authorize house, :update?
          house.update_attributes! declared_params
          HouseSynchronizer.with(house: house).update(:intercom)
        end
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

    desc "List Houses"
    params do
      optional :q, type: Hash
    end
    get do
      House.search(declared_params[:q])
    end
  end

end
