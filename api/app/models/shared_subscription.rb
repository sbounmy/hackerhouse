class SharedSubscription

  attr_reader :id

  def initialize house, customer:, trial_end:, cancel_at:
    @trial_end = trial_end
    @cancel_at = cancel_at
    @customer = customer
    @house = house
  end

  def save
    App.stripe do
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
        check_in: @trial_end,
        check_out: @cancel_at
      },
      trial_end: @trial_end.to_time.to_i
      # prorate: true
    }.tap do |p|
    end
  end

  def beginning_of_month?
    return true #todo : wait bugfix stripe
    @trial_end.day == 1
  end
end