require 'rails_helper'

feature 'house rent' do

  context 'with an existing house max users 4' do
    let(:hq) { create(:house, slug_id: 'hq', rent_monthly: 10_000) }
    let!(:nadia) { create(:user, house: hq, check: ['2017-09-02', '2017-11-15'] ) }
    let!(:brian) { create(:user, house: hq, check: ['2017-06-01', '2017-12-03'] ) }
    let!(:val)  { create(:user, house: hq, check: ['2017-06-01', '2017-12-03']) }
    let!(:hugo) { create(:user, house: hq, check: ['2017-06-01', '2017-12-03']) }

    scenario 'when someone replace Nadia' do
      visit "/gp/hq"
      expect(page).to have_content('Canal Street')
      select_date(2.months.from_now.beginning_of_month, from: '#check_in')
      select_date(4.months.from_now.end_of_month, from: '#check_out')

      check 'terms'
      click_on "customButton"

      expect {
        fill_credit_card
        expect(page).to have_no_css('.stripe_checkout_app')
        sleep 10
        alert = page.driver.browser.switch_to.alert
        expect(alert.text).to match /42 x Merci/
        alert.accept
      }.to change { User.count }.by(1)

      expect(
        HouseRent.new(hq, Date.today).users
      ).to contain_exactly([brian, 2250], [val, 2250], [hugo, 2250])
    end

  end

end
