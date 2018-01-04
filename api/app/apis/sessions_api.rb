class SessionsAPI < Grape::API

  resource :sessions do

    desc "Create a Session"
    params do
      requires :email,    type: String, desc: "User email"
      requires :password, type: String, desc: "User password"
    end

    post do
      command = AuthenticateUser.call(declared_params[:email],
                           declared_params[:password]).call
      if command.success?
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
