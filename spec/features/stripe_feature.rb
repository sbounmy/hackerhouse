require 'rails_helper'

feature 'checkout' do
  # let(:stripe) { StripeMock.create_test_helper }

  before do
    # StripeMock.start
    # stripe.create_plan(id: 'basic_monthly', amount: 52000)
  end

  # after { StripeMock.stop }
  scenario 'paying with correct card' do
    pk = "pk_test_TZNvputhVSjs6WFIZy4b4hH9"
    sk = "sk_test_4h4o1ck9feZX9VzinYNX4Vwm"
    visit "/stripe.html?pk=#{pk}"
    expect(page).to have_content 'Purchase'
    fill_in 'moving_on', with: 2.days.from_now.to_date.to_s
    click_on 'Purchase'
    create(:house, stripe_publishable_key: pk, stripe_access_token: sk)
    expect {
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)
  end
end