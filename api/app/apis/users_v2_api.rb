class UsersV2API < Grape::API
  version 'v2', using: :path

  resource :users do

    desc "Create an or updates an User by its email"
    params do
      requires :email,     type: String, regexp: /.+@.+/, coerce_with: ->(val) { val.downcase }
      requires :avatar_url,type: String, allow_blank: false
      requires :firstname, type: String, allow_blank: false
      requires :lastname,  type: String, allow_blank: false
      requires :bio_title, type: String, allow_blank: false
      requires :bio_url,   type: String, allow_blank: false

      optional :password,  type: String, description: "Linkedin creation does not require password"
      optional :linkedin_access_token, type: String
    end
    post do
      user = User.where(email: declared_params[:email]).first
      if user
        user.tap { |u| u.update_attributes! declared_params }
      else
        # generate default password from email: stephane@hackerhouse.paris -> stephane42
        declared_params[:password] ||= "#{declared_params[:email].split('@')[0]}42"
        User.create!(declared_params)
      end
    end

  end

end
