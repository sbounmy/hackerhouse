class UsersV2API < Grape::API
  version 'v2', using: :path

  resource :users do

    desc "Create an or updates an User by its email"
    params do
      requires :email,     type: String, regexp: /.+@.+/
      requires :avatar_url,type: String, allow_blank: false
      requires :password,  type: String, allow_blank: false
      requires :firstname, type: String, allow_blank: false
      requires :lastname,  type: String, allow_blank: false
      requires :bio_title, type: String, allow_blank: false
      requires :bio_url,   type: String, allow_blank: false
      optional :linkedin_access_token, type: String
    end
    post do
      user = User.where(email: declared_params[:email]).first
      if user
        user.tap { |u| u.update_attributes! declared_params }
      else
        User.create!(declared_params)
      end
    end

  end

end
