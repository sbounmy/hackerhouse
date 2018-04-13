module AppHelper
  extend ActiveSupport::Concern

  included do |base|
    RSpec.configure do |config|
      config.before(:each, type: :feature, rails: true) do
        Capybara.reset_sessions!
        Capybara.run_server = true
        Capybara.session_name = :remote_firefox2
        if /remote_firefox/.match Capybara.current_driver.to_s
          ip = `/sbin/ip route|awk '/scope/ { print $9 }'`
          ip = ip.gsub "\n", ""
          Capybara.server_port = "3000"
          Capybara.server_host = ip
          Capybara.app_host = "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}"
        end
        I18n.locale = :fr #for date picker
      end
    end
  end

end