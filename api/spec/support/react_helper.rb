module ReactHelper
  extend ActiveSupport::Concern

  included do
    RSpec.configure do |config|
      config.before(:each, type: :feature) do
        I18n.locale = :fr #for date picker
        Capybara.app_host = "http://test_app:3001"
        Capybara.run_server = false
      end

      config.after(:each, type: :feature) do
        Capybara.current_session.driver.quit
        Capybara.use_default_driver
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