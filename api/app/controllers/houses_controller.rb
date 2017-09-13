class HousesController < ApplicationController
  before_action :set_client
  
  def new
  end
  
  # 1. Finalize oauth2 by fetching token
  # 2. Retrieve account information : name
  # 3. Create House through /v1/houses api
  def token
    @token = @client.auth_code.get_token(params[:code])

    App.stripe do
      @account = Stripe::Account.retrieve(@token.params['stripe_user_id'])
    end
  end

  private 

  # https://connect.stripe.com/oauth/authorize?response_type=code&scope=read_write&client_id=#{}
  def set_client
    @client = OAuth2::Client.new(Rails.application.secrets.stripe_client_id,
    Rails.application.secrets.stripe_secret_key,
    site: "https://connect.stripe.com")
  end
end
