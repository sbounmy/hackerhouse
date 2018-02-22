class BalanceMailer < ApplicationMailer
  add_template_helper(GpHelper)

  default from: 'stephane@hackerhouse.paris'

  def pay_email(user, amount)
    @user = user
    @amount = amount
    @users_checkout_soon = user.house.users.active.asc(:check_out)
    mail(to: @user.email, subject: "#{Date.today} - Contribution Solidaire #{@user.house.slug_id}")
  end
end
