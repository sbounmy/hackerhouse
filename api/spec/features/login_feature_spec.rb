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
    sleep 10
    expect(page).to have_content 'Move ideas forward'
  end
end
