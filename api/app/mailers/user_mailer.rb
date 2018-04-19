class UserMailer < ApplicationMailer
  default from: 'julie@hackerhouse.paris', cc: 'stephane@hackerhouse.paris'

  def check_out_earlier_email(user)
    @user = user
    @house = @user.house
    @residents = @house.users.active.where(:id.ne => @user.id)
    @next = @residents.asc(:check_out).first
    mail(to: @residents.pluck(:email),
     from: from(@user.firstname).format,
     reply_to: @user.email,
     subject: "#{@user.firstname} nous quitte plus tôt que prévu ✈️",
     track_opens: 'true')
  end

  def check_out_later_email(user)
    @user = user
    @house = @user.house
    @residents = @house.users.active.where(:id.ne => @user.id)
    @next = @residents.asc(:check_out).first
    mail(to: @residents.pluck(:email),
         from: from(@user.firstname).format,
         reply_to: @user.email,
         subject: "#{@user.firstname} reste plus longtemps que prévu ! 👍",
         track_opens: 'true')
  end
end
