class HousesController < ApplicationController
  before_action :set_client
  
  def new
    @url = App.oauth_url(:stripe)
  end
  
  # 1. Finalize oauth2 by fetching token
  # 2. Retrieve account information : name
  # 3. Create House through /v1/houses api
  def token
    token = @client.auth_code.get_token(params[:code])
    App.stripe do
      Thread.new do
        Stripe::Account.retrieve(token.params['stripe_user_id']).tap do |a|
          params = {
            name: a.statement_descriptor,
            slug_id: a.statement_descriptor.split(' ').last.downcase.underscore,
            stripe_access_token: token.token,
            stripe_refresh_token: token.refresh_token,
            stripe_publishable_key: token.params['stripe_publishable_key'],
            stripe_id: token.params['stripe_user_id']
          } # weird timeout is happening. to fix this
          @response = api.post '/v1/houses', params
        end
      end #throw this in a thread so
    end
  end

  private 

  # https://connect.stripe.com/oauth/authorize?response_type=code&scope=read_write&client_id=#{}
  def set_client
    @client = OAuth2::Client.new(Rails.application.secrets.stripe_client_id,
    Rails.application.secrets.stripe_secret_key,
    site: "https://connect.stripe.com")
  end

  def api
    @faraday ||= Faraday::Connection.new(url: App.api_url) do |f|
      f.request  :url_encoded
      f.response :logger 
      f.options[:open_timeout] = 2
      f.options[:timeout] = 5
      f.adapter Faraday.default_adapter
    end
  end
end
