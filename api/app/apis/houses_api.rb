class HousesAPI < Grape::API

  resource :houses do
    route_param :slug_id do

      desc "Get a house"
      get do
        House.find_by(slug_id: params[:slug_id])
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
