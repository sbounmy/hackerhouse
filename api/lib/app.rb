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
    @prev = Stripe.api_key
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    @res = yield
  rescue Exception => e
    raise e
  ensure
    Stripe.api_key = @prev || nil
    @res
  end

  def self.intercom
    Intercom::Client.new(token: Rails.application.secrets.intercom_access_token).tap do |c|
      yield c if block_given?
    end
  end
end