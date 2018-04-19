# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  def check_out_earlier
    UserMailer.check_out_earlier_email(User.where(:house.ne => nil, :check_out.ne => nil).first)
  end

  def check_out_later
    UserMailer.check_out_later_email(User.where(:house.ne => nil, :check_out.ne => nil).first)
  end
end
