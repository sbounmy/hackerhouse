# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  def check_out_earlier
    UserMailer.with(user: user).check_out_earlier_email
  end

  def check_out_later
    UserMailer.with(user: user).check_out_later_email
  end

  def check_out_reminder
    UserMailer.with(user: user).check_out_reminder_email
  end

  private

  def user
    User.where(:house.ne => nil, :check_out.ne => nil).desc(:check_out).first
  end
end
