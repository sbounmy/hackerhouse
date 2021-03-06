require 'rails_helper'

feature 'login logout' do

  let(:hq) { create(:house) }

  scenario 'it logins through linkedin' do
    visit "/"
    expect(page).to have_content 'ideas'
    click_on "Let me"
    fill_in "session_key", with: 'julie@hackerhouse.paris'
    fill_in "session_password", with: 'qwertyqwerty'
    click_on("Sign in")
    click_on "Allow" if page.has_text?("HackerHouse would like to:")
    skip 'ci cant go through linkedin oauth' if page.has_text? 'This login attempt seems suspicious'
    expect(page).to have_content("Home")
    expect(page).to have_content('Julie A.I')
  end

  scenario 'it can log out' do
    signed_in_as(user = create(:user, house: nil))
    close_typeform
    expect(page).to have_css ".logout"
    find('.logout').click
    expect(page).to have_no_css('.logout')
    expect(page).to have_content('ideas')
  end

  scenario 'user without house should not see dashboard toggle' do
    signed_in_as(create(:user, house: nil))
    close_typeform
    expect(page).to have_no_content("Ma HackerHouse")
  end

end
