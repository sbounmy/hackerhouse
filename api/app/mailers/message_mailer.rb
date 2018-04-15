class MessageMailer < ApplicationMailer
  default from: 'julie@hackerhouse.paris', cc: 'stephane@hackerhouse.paris'

  def create_email(message)
    @message = message
    @user = message.user
    @house = message.house
    @residents = @house.users.active
    mail( to: @residents.pluck(:email),
          from: "#{@user.firstname} (HackerHouse) <#{@user.email}>",
          subject: "Nouveau message pour #{@house.name} du #{I18n.l @message.check_in, format: :long} - #{I18n.l @message.check_out, format: :long}",
          track_opens: 'true')
  end
end
