module FeatureHelper

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

end