class BalanceSynchronizer < ApplicationSynchronizer

  def create_stripe
    params[:balance].users.each do |item|
      App.stripe do
        # idempotency_key: safely retrying requests without accidentally performing the same operation twice.
        Stripe::InvoiceItem.create({
          customer: item[0].stripe_id,
          amount: item[1] * 100, currency: 'eur',
          description: "Contribution solidaire de #{I18n.l Date.today, format: :month}",
          }, idempotency_key: user_key(item[0]))
      end
    end
  end

  def create_mailer
    params[:balance].users.each do |item|
      BalanceMailer.pay_email(item[0], item[1]).deliver
    end
  end

  private

  def user_key user
    "#{Date.today.strftime('%Y-%m')}-#{user.stripe_id}"
  end

end