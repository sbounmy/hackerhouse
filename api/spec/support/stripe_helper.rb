module StripeHelper
  def fill_credit_card
    within_frame find('.stripe_checkout_app') do
      fill_in 'Email', with: 'paul@student.42.fr'
      fill_in 'Card number', with: '4242424242424242'
      fill_in 'MM / YY', with: '08/20'
      fill_in 'CVC', with: '999'

      find('.Section-button button').click
    end
  end
end