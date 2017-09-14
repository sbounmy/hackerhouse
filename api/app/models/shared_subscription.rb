class SharedSubscription

  def self.create stripe_id, amount, min_users, customer:, plans:, trial_end:
    quantity = Rent.new(trial_end, amount, trial_end, min_users).plus(1).quantity_per_user
    params = {
      customer: customer,
      items: plans.map { |pid| { plan: pid, quantity: quantity} },
      metadata: { account_id: stripe_id },
      trial_end: trial_end.to_i,
      prorate: false }
    App.stripe do
      Stripe::Subscription.create(params)
    end
  end
end