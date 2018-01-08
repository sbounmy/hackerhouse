require 'rails_helper'

feature 'iban' do
  # let(:stripe) { StripeMock.create_test_helper }

  before do
    # StripeMock.start
    # stripe.create_plan(id: 'basic_monthly', amount: 52000)
    I18n.locale = :fr #for date picker
  end

  it 'can add iban' do
    admin = create(:user, admin: true)
    user = create(:user, stripe: true)
    App.stripe do
      c = Stripe::Customer.retrieve(user.stripe_id)
      expect(c.sources.to_a.size).to eq 1
    end

    visit '/iban'
    fill_in "IBAN", with: 'FR76 3000 4008 2700 0016 4496 642'
    fill_in "Prenom Nom", with: "Stephane Bounmy"
    fill_in "user_id", with: user.id.to_s
    fill_in "token", with: token(admin)
    click_on "customButton"
    sleep 4
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to match /yay/
    App.stripe do
      c = Stripe::Customer.retrieve(user.stripe_id)
      expect(c.sources.to_a.size).to eq 2
    end
  end
end