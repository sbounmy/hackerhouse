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
    # visit "/stripe.html?pk=#{pk}"
    create(:house, slug_id: 'hq', stripe_publishable_key: pk, stripe_access_token: sk)
    visit "stripe.html?hh=hq"

    fill_in 'moving_on', with: 2.days.from_now.to_date.to_s
    click_on "customButton"
    expect {
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      sleep 1
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)
  end

  scenario 'when no matching house it should raise error' do
    create(:house, slug_id: 'hq')
    visit "stripe.html?hh=thefamily"
    expect(page).to have_content("T'es sur que le lien est bon")
  end

  scenario 'it displays custom price' do
    pk = "pk_test_TZNvputhVSjs6WFIZy4b4hH9"
    sk = "sk_test_4h4o1ck9feZX9VzinYNX4Vwm"
    # visit "/stripe.html?pk=#{pk}"
    create(:house, slug_id: 'hq', stripe_publishable_key: pk, stripe_access_token: sk, default_price: 79_000)

    visit "stripe.html?hh=hq"

    fill_in 'moving_on', with: 2.days.from_now.to_date.to_s
    click_on "customButton"
    expect {
      within_frame find('.stripe_checkout_app') do
        expect(page).to have_button('Pay €790.00')
      end
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      sleep 1
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)

  end
end