require 'rails_helper'

feature 'messages' do

  let(:hq) { create(:house) }

  scenario 'user with house can +1 user message' do
    julie = create(:user, email: 'julie@hackerhouse.paris', house: hq, check_out: 3.month.from_now)
    create(:message, house: hq)
    signed_in_as(julie)

    expect(page).to have_content("Ma HackerHouse")
    click_on "Ma HackerHouse"
    expect(page).to have_content "Salut, je suis"
    click_on "👍 0"
    expect(page).to have_content("👍 1")
  end

  scenario 'user without house cant +1 its own message' do
    julie = create(:user, email: 'julie@hackerhouse.paris', house: nil, check_out: 3.month.from_now)
    create(:message, user: julie, house: hq)
    signed_in_as(julie)

    expect(page).to have_no_content("Ma HackerHouse")
    expect(page).to have_content "Salut, je suis"
    click_on "👍 0"
    expect(page).to have_content("👍 0")
  end

end
