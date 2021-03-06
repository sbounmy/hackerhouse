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
    within('[data-qa-focused="true"]') { expect(page).to have_text(value) }
    # ci has a bug with .bd that obscures caption click. try to click on its container instead of element
    # find('.caption', text: value).first(:xpath,"./ancestor::li[contains(@class, 'container')]").click
    # find('.caption', text: value).click
    find('[data-qa="choice"]', text: value).click
  end

  def tf_fill_in(selector, with: '')
    within('[data-qa-focused="true"]') { expect(page).to have_text(selector) }
    find('[data-qa-block="true"]', text: selector).first(:xpath,".//..").find('input, textarea').tap do |input|
      input.set with
      input.send_keys :return
    end
  end

  def tf_submit
    find('[data-qa="submit-button"]').click
  end
end