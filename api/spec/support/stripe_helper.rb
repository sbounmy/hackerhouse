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

  NEXT_MONTH = '.flatpickr-next-month'
  PREV_MONTH = '.flatpickr-prev-month'

  def date_diff2_in_months(start_date, end_date)
    (to_months(start_date) - to_months(end_date)).abs
  end

  def to_months(date)
    (date.year * 12 + date.month)
  end

  ## select target date and flip through the calendar
  def select_dates(from:, to:)
    months_ahead = date_diff2_in_months(Date.today, from)
    find('.flatpickr-input').click
    # define next month selector used into flip date picker method
    # if days.to_i < 0
    #   navigator = find(PREV_MONTH)
    # else
      navigator = find(NEXT_MONTH)
    # end
    # flip over the date picker to the target calculated month
    flip_date_picker(navigator, months_ahead) if months_ahead > 0
    select_date(from)

    months_ahead = date_diff2_in_months(from, to)

    flip_date_picker(navigator, months_ahead) if months_ahead > 0
    select_date(to)
    expect(page).to have_no_css('.flatpickr-calendar')
  end

  def flip_date_picker(element, months)
    for i in 1..months do
      element.click
    end
  end

  def select_date(date)
     date = I18n.l(date, format: "%B %-d, %Y").capitalize
     find(:xpath, "//span[contains(@class, 'flatpickr-day') and @aria-label='#{date}']").click
   end
end