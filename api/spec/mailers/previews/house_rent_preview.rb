# Preview all emails at http://localhost:3000/rails/mailers/house_rent
class HouseRentPreview < ActionMailer::Preview
  def pay
    HouseRentMailer.pay_email(User.first, 445)
  end
end
