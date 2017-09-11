class Rent

  def initialize(house, time=Time.now)
    @end = time.end_of_month.end_of_day
    raise 'cannot initialize past month date' if @end.end_of_month < Time.now.end_of_month
    @house = house    
    @time = time
  end

  def amount
    @house.amount / users.count
  end

  def amount_round
    (amount.to_f / 100).ceil * 100
  end

  def users
    User.where(:stripe_id.in => customer_ids)
  end

  def update!
    active_subscriptions.each do |s|
      s.quantity = amount_round
      s.save
    end
  end

  private 

  def active_subscription? s
    return false if s.status == 'canceled'
    if s.cancel_at_period_end?
      s.current_period_end >= @end.to_i #end after current end of month
    elsif s.trial_end.nil?
      true
    else
       Time.at(s.trial_end).beginning_of_day.to_i <= @end.to_i
    end
      
  end

  def active_subscriptions
    @house.stripe do
      @subscriptions ||= Stripe::Subscription.list(limit: 100).select {|s| active_subscription? s }    
    end
  end

  def customer_ids
    active_subscriptions.map &:customer
  end
end