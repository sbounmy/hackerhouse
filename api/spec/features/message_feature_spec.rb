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

  scenario 'user without house who already applied, doesnt popup' do
    julie = create(:user, email: 'julie@hackerhouse.paris', house: nil, check_out: 3.month.from_now)
    create(:message, user: julie, house: hq)
    signed_in_as(julie)
    expect(page).to have_no_css('[alt=close-typeform]') # wait for typeform to close properly

    expect(page).to have_no_content("Ma HackerHouse")
    expect(page).to have_content "Salut, je suis"
  end

  scenario 'user who never applied should see popup and welcome message' do
    julie = create(:user, firstname: 'Julie', email: 'julie@hackerhouse.paris', house: nil, check_out: 3.month.from_now)
    signed_in_as(julie)
    expect(page).to have_css('[alt=close-typeform]', wait: 10) # wait for typeform to close properly
    within_frame(0) do
      expect(page).to have_content("Hello World Julie")
      expect(page).to have_content("Hello World Julie-SANDBOX_TYPEFORM")
    end

    within_intercom :notifications do
      expect(page).to have_content 'Vraiment désolé Julie'
    end
  end

  scenario 'user who fill the form should get onboard' do
    julie = create(:user, firstname: 'Julie', email: 'julie@hackerhouse.paris', house: nil, check_out: 3.month.from_now)
    signed_in_as(julie)
    expect(page).to have_css('[alt=close-typeform]', wait: 10) # wait for typeform to close properly

    within_frame(0) do
      expect(page).to have_content("Hello World Julie-SANDBOX_TYPEFORM")

      find('.button.general', text: "HACKERHOUSE.GO").click
      tf_select(/HQ #blockchain #dev/)
      tf_select(/DEV/)
      tf_select(/Ta valise/)
      tf_fill_in('phone', with: '0566443322')
      tf_fill_in(/Date d\'arriv/, with: '11/08/2018')
      tf_fill_in(/Date de d/, with: '31/10/2020')
      tf_fill_in(/Pitch ta startup/, with: build(:message).body)
      sleep 1 #wait scroll unfixed footer
      find('.submit').click

      expect(page).to have_text('Super ! On te contactera sur julie@hackerhouse.paris')
    end

    within_intercom :notifications do
      expect(page).to have_content 'Je viens de prévenir les colocs de ton inscription !'
    end
  end

  scenario 'user who check out should not see house data'
end
