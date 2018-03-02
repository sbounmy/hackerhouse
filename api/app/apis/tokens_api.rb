class TokensAPI < Grape::API

  resource :tokens do
    params do
      requires :code, allow_blank: false
      requires :redirect_uri, allow_blank: false
    end
    get 'linkedin' do
      @client = OAuth2::Client.new(Rails.application.secrets.linkedin_client_id, Rails.application.secrets.linkedin_secret_key, site: "https://www.linkedin.com", token_url: "/oauth/v2/accessToken")
      @token = @client.auth_code.get_token(declared_params[:code], redirect_uri: URI.unescape(declared_params[:redirect_uri]))
      profile_url = "https://api.linkedin.com/v1/people/~:(id,email-address,first-name,last-name,headline,picture-url,picture-urls::(original),public-profile-url,specialties,industry,location,positions)"
      Token.from_linkedin @token.token, JSON.parse(@token.get(profile_url, params: { format: 'json' }).response.body)
    end
  end
end
