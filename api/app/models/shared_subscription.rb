class SharedSubscription

  def self.create house, customer:, trial_end:
    params = {
      customer: customer,
      items: house.stripe_items,
      metadata: { account_id: house.stripe_id },
      trial_end: trial_end.to_i }

    App.stripe do
      Stripe::Subscription.create(params)
    end
  end
end