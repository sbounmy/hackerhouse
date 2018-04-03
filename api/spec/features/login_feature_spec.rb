require 'rails_helper'

feature 'checkout' do
  # let(:stripe) { StripeMock.create_test_helper }

  before do
    # StripeMock.start
    # stripe.create_plan(id: 'basic_monthly', amount: 52000)
    I18n.locale = :fr #for date picker
    Capybara.app_host = "http://test_app:3001"
  end

  # after { StripeMock.stop }
  scenario 'it logins through linkedin' do
    visit "/"
    expect(page).to have_content 'ideas'
    click_on "Let me"

    fill_in "session_key", with: "julie@hackerhouse.paris"
    fill_in "session_password", with: "qwertyqwerty"
    page.execute_script("$('.btn-signin').click();")

    click_on "Allow" if page.has_text?("HackerHouse would like to:")
    expect(page).to have_content("Julie")
  end

end
