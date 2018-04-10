class MessagesAPI < Grape::API

  resource :messages do

    route_param :id do
      desc "Get a Message"
      get do
        Message.find(params[:id])
      end

      desc 'Adds a thumb to message'
      params do
        requires :like_id,    type: String, desc: "Liked by User id"
      end
      put 'like' do
        Message.find(params[:id]).tap do |message|
          user_id = declared_params[:like_id]
          authorize message, :like?
          raise Pundit::NotAuthorizedError if !current_user.admin? && current_user.id.to_s != user_id
          message.add_to_set like_ids: user_id
        end
      end

      desc 'Removes a thumb to message'
      params do
        requires :like_id,    type: String, desc: "Unliked by User id"
      end
      delete 'like' do
        Message.find(params[:id]).tap do |message|
          user_id = declared_params[:like_id]
          authorize message, :like?
          raise Pundit::NotAuthorizedError if !current_user.admin? && current_user.id.to_s != user_id
          message.pull like_ids: user_id
        end
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
