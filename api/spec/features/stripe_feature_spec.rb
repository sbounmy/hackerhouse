require 'rails_helper'

feature 'checkout', :rails do
  scenario 'paying with correct card' do
    pk = "pk_test_TZNvputhVSjs6WFIZy4b4hH9"
    sk = "sk_test_4h4o1ck9feZX9VzinYNX4Vwm"
    # visit "/stripe.html?pk=#{pk}"
    create(:house, slug_id: 'ivry', stripe_publishable_key: pk, stripe_access_token: sk, v2: false,
      stripe_plan_ids: ['work_monthly', 'sleep_monthly'])

    visit "/gp/ivry"

    select_date(2.months.from_now, from: '#check_in')
    select_date(4.months.from_now, from: '#check_out')

    # check 'terms'
    click_on "customButton"
    expect {
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      sleep 4
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)
  end

  scenario 'when no matching house it should raise error' do
    create(:house, slug_id: 'hq', v2: false)
    visit "/gp/thefamily"
    Capybara.raise_server_errors = false
    expect(page).to have_content('not found')
  end

  scenario 'it can have a custom plan' do
    pk = "pk_test_TZNvputhVSjs6WFIZy4b4hH9"
    sk = "sk_test_4h4o1ck9feZX9VzinYNX4Vwm"
    create(:house, name: 'SuperNana House', slug_id: 'supernana',
      stripe_publishable_key: pk, stripe_access_token: sk, stripe_plan_ids: ['sleep_monthly'], v2: false)

    visit "/gp/supernana"
    expect(page).to have_content("SuperNana House")

    select_date(2.months.from_now, from: '#check_in')
    select_date(4.months.from_now, from: '#check_out')

    click_on "customButton"
    expect {
      within_frame find('.stripe_checkout_app') do
        expect(page).to have_button('Pay €220.00')
      end
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      sleep 4

      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)
  end

  scenario 'when paying v2 at beginning_of_month' do
    create(:house, name: "HackerHouse VH", slug_id: 'vh', stripe: true)
    visit "/gp/vh"
    expect(page).to have_content('VH')
    select_date(2.months.from_now.beginning_of_month, from: '#check_in')
    select_date(4.months.from_now.end_of_month, from: '#check_out')

    check 'terms'
    click_on "customButton"

    expect {
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      sleep 15
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)
    user = User.last
    expect(user.check).to eq [2.months.from_now.beginning_of_month.to_date, 4.months.from_now.end_of_month.to_date]
    # no prorata invoice
    App.stripe do
      subs = Stripe::Subscription.list(customer: User.last.stripe_id).data
      expect(subs).to have(1).items
      invoices = Stripe::Invoice.list(customer: User.last.stripe_id).data
      expect(invoices).to have(1).items
      expect(invoices[0].amount_due).to be 0
    end
  end

  scenario 'when paying v2 in middle of month' do
    create(:house, name: "HackerHouse VH", slug_id: 'vh', stripe: true)
    visit "/gp/vh"
    expect(page).to have_content('VH')
    next_mid_month = Date.new(3.month.from_now.year, 3.month.from_now.month, 15)
    select_date(next_mid_month, from: '#check_in')
    select_date(4.months.from_now.end_of_month, from: '#check_out')

    check 'terms'
    click_on "customButton"

    expect {
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      sleep 15
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)
    # no prorate flag on subscription
    days_to_prorate = (next_mid_month.next_month.beginning_of_month.to_date - User.last.check_in).to_i
    App.stripe do
      subs = Stripe::Subscription.list(customer: User.last.stripe_id).data
      expect(subs).to have(1).items
      invoices = Stripe::Invoice.list(customer: User.last.stripe_id).data
      expect(invoices).to have(2).items
      expect(invoices[0].lines.data).to have(3).items
      total = ((500.to_f / 4 / 31 * days_to_prorate).ceil + (10000.to_f / 4 / 31 * days_to_prorate).ceil) * 100
      expect(invoices[0].amount_due).to eq total
    end
  end

  scenario 'when paying v2 today' do
    pending 'not supported'
    create(:house, name: "HackerHouse VH", slug_id: 'vh', stripe_id: 'acct_1B1FYLBnBiKe4QYN')
    visit "/gp/vh"
    expect(page).to have_content('VH')
    select_date(Date.today.beginning_of_month, from: '#check_in')
    select_date(4.months.from_now.end_of_month, from: '#check_out')

    check 'terms'
    click_on "customButton"

    expect {
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to change { User.count }.by(1)
    # no prorate flag on subscription
    # App.stripe do
    #   expect(Stripe::Subscription.retrieve(User.last.stripe_subscription_ids[0]).prorate).to eq false
    # end
  end

  it 'updates existing user' do
    user = create(:user, email: 'paul@student.42.fr')
    house = create(:house, name: "HackerHouse VH", slug_id: 'vh', stripe: true)
    visit "/gp/vh"
    expect(page).to have_content('VH')
    next_mid_month = Date.new(3.month.from_now.year, 3.month.from_now.month, 15)
    select_date(next_mid_month, from: '#check_in')
    select_date(4.months.from_now.end_of_month, from: '#check_out')

    check 'terms'
    click_on "customButton"

    expect {
      fill_credit_card
      expect(page).to have_no_css('.stripe_checkout_app')
      sleep 15
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match /42 x Merci/
      alert.accept
    }.to_not change { User.count }

    expect(user.reload.token).to_not be_nil
    expect(user.stripe_id).to_not be_nil
    expect(user.house).to eq house
    expect(user.check).to eq [ next_mid_month, 4.months.from_now.end_of_month.to_date]
  end
end