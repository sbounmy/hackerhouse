class SessionsAPI < Grape::API

  resource :sessions do

    desc "Create a Session"
    params do
      requires :email,    type: String, desc: "User email"
      optional :password, type: String, desc: "User password"
      optional :linkedin_access_token, type: String
      at_least_one_of :password, :linkedin_access_token
    end

    post do
      command = AuthenticateUser.call(declared_params[:email],
                           declared_params[:password],
                           declared_params[:linkedin_access_token]).call
      if command.success?
        params[:token] = command.token #set token so serializer get the current_user to show email and protected attributes
        command.result
      else
        error!({ 'errors' => { 'forbidden' => 'wrong email or password' } }, 401)
      end
    end

    params do
      optional :token, type: String
    end
    get do
      if user = AuthorizeApiRequest.call(params[:token], request.headers).result
        Session.new(declared_params[:token], user)
      else
        error!('invalid', 403)
      end
    end

  end
end
