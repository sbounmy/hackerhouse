class App
  API_CONFIG = Rails.application.config_for(:api)
  OAUTH_CONFIG = Rails.application.config_for(:oauth)

  def self.api_url
    API_CONFIG['url']
  end

  def self.oauth_url(name)
    OAUTH_CONFIG[name.to_s]['redirect_url']
  end

  def self.stripe
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    @res = yield
  rescue Exception => e
    raise e
  ensure
    Stripe.api_key = nil
    @res
  end
end