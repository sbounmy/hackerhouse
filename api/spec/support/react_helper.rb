module ReactHelper
  extend ActiveSupport::Concern

  included do
    RSpec.configure do |config|
      # this force to boot rails app
      config.before(:suite) do
        puts "booting default server..."
        ip = `/sbin/ip route|awk '/scope/ { print $9 }'`
        ip = ip.gsub "\n", ""
        Capybara.server_port = "3000"
        Capybara.server_host = ip
        Capybara.current_session.server.boot
      end

      config.before(:each, type: :feature) do |example|
        I18n.locale = :fr #for date picker
        if example.metadata[:rails]
          Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
        else
          Capybara.app_host = "http://test_app:3001"
        end
      end

      config.after(:each, type: :feature) do |example|
        if example.exception
          meta = example.metadata
          name = "test-failure-#{File.basename(meta[:file_path])}-#{meta[:line_number]}.png"

          # Save screenshots in CI
          screenshot_root_path = ENV["CIRCLE_ARTIFACTS"] || Rails.root.join("tmp", "capybara")

          screenshot_path = [screenshot_root_path, name].join("/")

          page.save_screenshot(screenshot_path, full: true)
          $stdout << "\nScreenshot Taken: #{screenshot_path}\n"
        end
        page.execute_script("localStorage && localStorage.clear()")
      end
    end
  end

  def close_typeform
    expect(page).to have_css('[alt=close-typeform]', visible: true, wait: 10) # wait for typeform to load properly
    page.execute_script("document.querySelectorAll('[alt=close-typeform]')[0].click()")
    expect(page).to have_no_css('[alt=close-typeform]', visible: false) # wait for typeform to close properly
  end

  def signed_in_as(user)
    visit "/"
    expect(page).to have_content('ideas')
    token = JsonWebToken.encode(user_id: user.id.to_s)
    page.execute_script("localStorage.setItem(\"token\", \"#{token}\")")
    visit "/"
    expect(page).to have_content('Home')
  end
end