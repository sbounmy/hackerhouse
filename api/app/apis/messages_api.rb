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

      requires :house_id,               type: String, desc: 'House id'
      requires :body,                   type: String, desc: "Description"
    end
    post do
      declared_params[:user_id] = current_user.id
      Message.new(declared_params).tap do |message|
        authorize message, :create?
        message.save!
      end
    end
  end

end
