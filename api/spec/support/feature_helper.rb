module FeatureHelper
  INTERCOM_TYPES = [:notifications, :messenger, :borderless]

  def close_typeform
    expect(page).to have_css('[alt=close-typeform]', visible: true, wait: 10) # wait for typeform to load properly
    page.execute_script("document.querySelectorAll('[alt=close-typeform]')[0].click()")
    expect(page).to have_no_css('[alt=close-typeform]', visible: false) # wait for typeform to close properly
  end

  def signed_in_as(user)
    visit "/"
    token = JsonWebToken.encode(user_id: user.id.to_s)
    page.execute_script("localStorage.setItem(\"token\", \"#{token}\")")
    visit "/"
    expect(page).to have_content('Home')
  end

  def within_intercom(type, &block)
    raise "Type should be within #{INTERCOM_TYPES.inspect}" unless INTERCOM_TYPES.include? type.to_sym
    within_frame "intercom-#{type}-frame", &block
  end

  def tf_select(value)
    within('.focus') { expect(page).to have_text(value) }
    find('.caption', text: value).click
  end

  def tf_fill_in(selector, with: '')
    within('.focus') { expect(page).to have_text(selector) }
    find('.question', text: selector).first(:xpath,".//..").find('input, textarea').set with
    find('.focus').send_keys :return
  end
end