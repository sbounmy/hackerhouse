require 'rails_helper'

feature 'third party widgets' do

  scenario 'does not load hoatjar in test' do
    visit '/'
    expect(page).to have_content 'ideas'
    expect(page).to have_no_css('script[src*="hotjar"]', visible: false)
  end

end