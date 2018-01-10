require 'rails_helper'

feature 'checkout' do
  # let(:stripe) { StripeMock.create_test_helper }

  before do
    # StripeMock.start
    # stripe.create_plan(id: 'basic_monthly', amount: 52000)
    I18n.locale = :fr #for date picker
  end

  # after { StripeMock.stop }
  scenario 'when creating new house' do
    visit '/houses/new'
    click_on "Créer mon compte stripe"
    within_window(page.windows.last) do
      n = SecureRandom.urlsafe_base64(4)
      expect(page).to have_content('HackerHouse would like you to start accepting payments with Stripe.')

      find_field('biz_country').select 'France'
      # select "France", from: '.field[name="biz_country"]'
      fill_in "product_description", with: "Espace de coworking H24"

      fill_in "biz_street", with: "14 rue des peupliers"
      fill_in "biz_zip", with: "75001"
      # page.execute_script(%Q{$("input[name='biz_zip']").trigger("change")})

      fill_in "url", with: "https://hackerhouse.paris"

      fill_in "owner_first_name", with: "Stephane"
      fill_in "owner_last_name", with: "Boubou"
      fill_in "owner_dob_day", with: 19
      fill_in "owner_dob_mon", with: 12
      fill_in "owner_dob_year", with: 1990
      fill_in "owner_street", with: "14 rue des peupliers"
      fill_in "owner_zip", with: "75001"

      fill_in "biz_dba", with: "HackerHouse #{n}"
      fill_in "biz_phone_no", with: "+33142356644"

      fill_in 'account_number', with: 'FR1420041010050500013M02606'
      page.execute_script(%Q{$("input[name='account_number']").trigger("change")})
      expect(page).to have_content 'Bank: La Banque Postale'
      fill_in 'account_number_validate', with: 'FR1420041010050500013M02606'

      fill_in 'email', with: "stephane+#{n}@hackerhouse.paris"
      fill_in 'password', with: 'My-top-secret-password42'

      expect {
        click_on("Authorize access to this account")
        expect(page).to have_content("HackerHouse créé avec succès !", wait: 1000)
      }.to change { House.count }.by(1)
    end

  end
end
