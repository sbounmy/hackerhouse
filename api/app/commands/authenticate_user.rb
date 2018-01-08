class AuthenticateUser
  prepend SimpleCommand

  def initialize(email, password, linkedin_access_token=nil)
    @email = email
    @password = password
    @linkedin_access_token = linkedin_access_token
  end

  def call
    if user
      Session.new(token, user)
    end
  end

  def token
    JsonWebToken.encode(user_id: user.id.to_s)
  end

  private

  attr_accessor :email, :password

  def user
    user = User.find_by(email: email)
    return user if user && user.authenticate(password)
    return user if user && user.authenticate_linkedin(@linkedin_access_token)

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end
