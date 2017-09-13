class App
  API_CONFIG = Rails.application.config_for(:api)
  
  def self.api_url
    API_CONFIG['url']
  end

  def self.stripe
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    yield
  rescue Exception => e
    raise e
  ensure
    Stripe.api_key = nil
  end
end