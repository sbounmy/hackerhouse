class SharedSubscription

  attr_reader :id

  def initialize house, customer:, check_in:, check_out:
    @check_in = check_in
    @check_out = check_out
    @customer = customer
    @house = house
  end

  def save
    App.stripe do
      Stripe::Subscription.create(once_params) if not beginning_of_month?

      Stripe::Subscription.create(params).tap do |s|
        @id = s.id
      end
    end
  end

  def params
     {
      customer: @customer,
      items: @house.stripe_items,
      metadata: {
        account_id: @house.stripe_id,
        house: @house.slug_id,
        check_in: @check_in,
        check_out: @check_out
      },
      trial_end: next_billing_cycle_date.to_time.to_i
    }
  end

  def beginning_of_month?
    @check_in.day == 1
  end

  def next_billing_cycle_date
    beginning_of_month? ? @check_in : @check_in.next_month.beginning_of_month.to_date
  end

  # -1 to not count first day of next month
  def days_to_prorate
    (next_billing_cycle_date - @check_in).to_i
  end

  def once_params
    items = @house.stripe_items
    items.each do |obj|
      obj[:quantity] = (obj[:quantity].to_f / 31 * days_to_prorate).ceil
    end

    {
      customer: @customer,
      items: items,
      metadata: {
        account_id: @house.stripe_id,
        house: @house.slug_id,
        check_in: @check_in,
        check_out: @check_out,
        once: true
      },
      trial_end: @check_in.to_time.to_i
      # prorate: true
    }
  end
end