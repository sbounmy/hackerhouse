# Preview all emails at http://localhost:3000/rails/mailers/balance
class BalancePreview < ActionMailer::Preview
  def pay
    BalanceMailer.pay_email(User.first, 445)
  end
end
