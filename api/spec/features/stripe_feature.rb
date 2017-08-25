require 'rails_helper'

feature 'checkout' do
  # let(:stripe) { StripeMock.create_test_helper }

  before do
    # StripeMock.start
    # stripe.create_plan(id: 'basic_monthly', amount: 52000)
    I18n.locale = :fr #for date picker
  end

  # after { StripeMock.stop }
  scenario 'paying with correct card' do
    pk = "pk_test_TZNvputhVSjs6WFIZy4b4hH9"
    sk = "sk_test_4h4o1ck9feZX9VzinYNX4Vwm"
    # visit "/stripe.html?pk=#{pk}"
    create(:house, slug_id: 'hq', stripe_publishable_key: pk, stripe_access_token: sk)
    visit "/gp/hq"

    select_date(2.months.from_now, from: '#check_in')
    select_date(4.months.from_now, from: '#check_out')

    check 'terms'
    click_on "customButton"
    expect {
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      sleep 5
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)
  end

  scenario 'when no matching house it should raise error' do
    create(:house, slug_id: 'hq')
    visit "/gp/thefamily"
    Capybara.raise_server_errors = false
    expect(page).to have_content('Document not found')
  end

  scenario 'it can have a custom plan' do
    pk = "pk_test_TZNvputhVSjs6WFIZy4b4hH9"
    sk = "sk_test_4h4o1ck9feZX9VzinYNX4Vwm"
    create(:house, name: 'SuperNana House', slug_id: 'supernana', stripe_publishable_key: pk, stripe_access_token: sk, stripe_plan_ids: ['sleep_monthly'])

    visit "/gp/supernana"
    expect(page).to have_content("SuperNana House")

    select_date(2.months.from_now, from: '#check_in')
    select_date(4.months.from_now, from: '#check_out')

    check 'terms'
    click_on "customButton"
    expect {
      within_frame find('.stripe_checkout_app') do
        expect(page).to have_button('Pay €200.00')
      end
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      sleep 5

      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)
  end
end