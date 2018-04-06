require 'rails_helper'

feature 'checkout' do
  # let(:stripe) { StripeMock.create_test_helper }

  before do
    # StripeMock.start
    # stripe.create_plan(id: 'basic_monthly', amount: 52000)
    I18n.locale = :fr #for date picker
    Capybara.app_host = "http://test_app:3001"
    Capybara.run_server = false
  end

  def login_as email, password
    visit "/"
    expect(page).to have_content 'ideas'
    click_on "Let me"

    fill_in "session_key", with: email
    fill_in "session_password", with: password
    page.execute_script("$('.btn-signin').click();")
    click_on "Allow" if page.has_text?("HackerHouse would like to:")
    expect(page).to have_content("Home")
  end

  # after { StripeMock.stop }
  scenario 'it logins through linkedin' do
    login_as 'julie@hackerhouse.paris', 'qwertyqwerty'
  end

  scenario 'it can check out' do
    login_as 'julie@hackerhouse.paris', 'qwertyqwerty'
    julie = User.find_by(email: 'julie@hackerhouse.paris')
    house = create(:house)
    create(:message, user: julie, house: house)
    visit "/"
    expect(page).to have_content "Salut"
  end

  scenario 'user without house should not see dashboard toggle' do
    login_as 'julie@hackerhouse.paris', 'qwertyqwerty'
    close_typeform
    expect(page).to have_no_content("Ma HackerHouse")
  end

  scenario 'user with house can +1 user message' do

  end
end
