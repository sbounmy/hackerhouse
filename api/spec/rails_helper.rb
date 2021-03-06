# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'rspec/collection_matchers'
require 'capybara/rails'
require 'capybara/rspec'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include ControllerHelper
  config.include SlackHelper
  config.include StripeHelper, type: :feature
  config.include ReactHelper,  type: :feature
  config.include FeatureHelper,  type: :feature

  # Make sure we dont synchronize to third parties
  # Even if it targets 3rd party sandbox
  config.before(:each) do |example|
    params = {}
    params[:except] = if example.metadata[:sync] === true
      [anything]
    else
      example.metadata[:sync]
    end
    stub_synchronizers! params
  end

  # Wipe database to have a clean test environment
  config.after(:each) do
    Mongoid::Config.purge!
    deliveries.clear
  end

  config.before(type: :feature) do
    Rails.application.config.action_dispatch.show_exceptions = true
  end

  config.after(type: :feature) do
    Rails.application.config.action_dispatch.show_exceptions = false
    Capybara.use_default_driver
  end

  # let spec/apis/* access to request helpers : get, post, put ...
  config.include RSpec::Rails::RequestExampleGroup, type: :request, parent_example_group: {
    file_path: /spec\/api/
  }

end

StripeMock.default_currency = 'eur'

docker_ip = %x(/sbin/ip route|awk '/default/ { print $3 }').strip
# Capybara.server_host = '0.0.0.0'
# Capybara.server_port = "3010"
Capybara.default_driver = :remote_firefox
Capybara.default_max_wait_time = 5
# Capybara.app_host = "http://#{docker_ip}:3010"

Capybara.register_driver :remote_firefox do |app|
  firefox_capabilities = Selenium::WebDriver::Remote::Capabilities.firefox()
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile["intl.accept_languages"] =  "en-US"
  options = Selenium::WebDriver::Firefox::Options.new
  options.profile = profile
  Capybara::Selenium::Driver.new(app, browser: :remote,
    url: "http://#{ENV['SELENIUM_REMOTE_HOST']}:4444/wd/hub", desired_capabilities: firefox_capabilities)
end