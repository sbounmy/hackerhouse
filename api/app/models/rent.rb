class Rent

  def initialize(stripe_id, amount, date_or_time=Time.now, min=1)
    @end = date_or_time.to_time.end_of_month.end_of_day
    raise 'cannot initialize past month date' if @end.end_of_month < Time.now.end_of_month
    @time = date_or_time
    @stripe_id = stripe_id
    @amount = amount
    @min = min
    @n = 0
  end

  def amount_per_user
    @amount / users_count
  end

  def users_count
    [ active_subscriptions.count + @n, @min ].max
  end

  def quantity_per_user
    (amount_per_user.to_f / 100).ceil 
  end

  def plus(n)
    @n += n
    self
  end
  # def users
  #   User.where(:stripe_id.in => customer_ids).tap do |users|
  #     raise "missing customer in api : #{customer_ids - users.map(&:stripe_id)}" if users.size != customer_ids.size
  #   end
  # end

  def update!
    active_subscriptions.each do |s|
      s.items.each do |item|
        item.quantity = quantity_per_user
        item.save
      end
    end
  end

  private 

  def active_subscription? s
    return false if s.status == 'canceled'
    # Return false if customer does not belong to current house stripe id
    return false if s.metadata['account_id'] != @stripe_id

    if s.cancel_at_period_end?
      s.current_period_end >= @end.to_i #end after current end of month
    elsif s.trial_end.nil?
      true
    else
      Time.at(s.trial_end).beginning_of_day.to_i <= @end.to_i
    end
  end

  # TODO: this should be refactored using cursor pagination
  def active_subscriptions
    App.stripe do
      @subscriptions ||= Stripe::Subscription.list(limit: 100)
      .select {|s| active_subscription? s }    
    end
  end

  def customer_ids
    active_subscriptions.map &:customer
  end
end