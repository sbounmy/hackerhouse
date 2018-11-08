class SharedSubscription

  attr_reader :id, :prorata_id

  def initialize house, customer:, check_in:, check_out:
    @check_in = check_in
    @check_out = check_out
    @customer = customer
    @house = house
  end

  def save
    App.stripe do
      Stripe::Subscription.create(params).tap do |s|
        @id = s.id
      end

      create_prorata if not beginning_of_month?
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
      trial_end: next_billing_cycle_date.to_time.to_i,
      tax_percent: @house.tax_percent
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

  def create_prorata
    items = @house.subscription_items
    items.each do |product_id, product|
      Stripe::InvoiceItem.create({
        customer: @customer,
        amount: (product[:quantity].to_f / 31 * days_to_prorate).ceil * 100, currency: 'eur',
        description: "Prorata #{product[:name]} de #{days_to_prorate} jours",
      }, idempotency_key: user_key(product_id))
    end
    invoice = Stripe::Invoice.create customer: @customer,
              billing: 'send_invoice', due_date: @check_in.to_time.to_i,
              tax_percent: @house.tax_percent
    @prorata_id = invoice.id
  end

  def user_key any_id
    "#{Date.today.strftime('%Y-%m')}-#{@customer}-#{any_id}"
  end

end