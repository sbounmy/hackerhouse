class SharedSubscription

  attr_reader :id

  def initialize house, customer:, trial_end:
    @trial_end = trial_end
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
      metadata: { account_id: @house.stripe_id },
      trial_end: @trial_end.to_i
      # prorate: true
    }.tap do |p|
      p.merge!(billing_cycle_anchor: @trial_end.at_beginning_of_month.next_month.to_time.to_i) if not beginning_of_month?
    end
  end

  def beginning_of_month?
    return true #todo : wait bugfix stripe
    @trial_end.day == 1
  end
end