class BalanceMailer < ApplicationMailer
  add_template_helper(GpHelper)

  default from: 'nadia@hackerhouse.paris'

  def pay_email(user, amount)
    @user = user
    @amount = amount
    mail(to: @user.email, subject: "#{Date.today} - Contribution Solidaire #{@user.house.slug_id}")
  end
end
