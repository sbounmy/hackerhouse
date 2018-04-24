class UserMailer < ApplicationMailer
  default from: -> { from.format },
          reply_to: -> { @user.email },
          to: -> { @residents.pluck(:email) },
          cc: 'stephane@hackerhouse.paris',
          track_opens: true

  before_action do
    @user = params[:user]
    @house = @user.house
    @residents = @house.users.active.where(:id.ne => @user.id)
    @next = @residents.asc(:check_out).first
  end

  def check_out_earlier_email
    mail subject: "#{@user.firstname} nous quitte plus tôt que prévu ✈️"
  end

  def check_out_later_email
    mail subject: "#{@user.firstname} reste plus longtemps que prévu ! 👍"
  end
end
