class MessagesAPI < Grape::API

  resource :messages do

    route_param :id do
      desc "Get a Message"
      get do
        Message.find(params[:id])
      end
    end

    params do
      requires :check_in,               type: Date,   desc: 'Check in date'
      requires :check_out,              type: Date,   desc: 'Check out date'

      requires :user_id,                type: String,   desc: 'User initiator id'
      requires :house_id,               type: String, desc: 'House id'
      requires :body,                   type: String, desc: "Description"
    end
    post do
      Message.new(declared_params).tap do |message|
        authorize message, :create?
        message.save!
      end
    end

    desc "List Messages"
    params do
      optional :q, type: Hash
    end
    get do
      Message.search(declared_params[:q])
    end
  end

end
