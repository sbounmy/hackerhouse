class Session
  include ActiveModel::Serializers::JSON
  attr_accessor :token, :user

  def initialize(token, user)
    @token = token
    @user = user
  end
end