class MessageMailer < ApplicationMailer
  default from: -> { from(@user.firstname).format },
          cc: 'stephane@hackerhouse.paris'

  def create_email(message)
    @message = message
    @user = message.user
    @house = message.house
    @residents = @house.users.active

    mail(to: @residents.pluck(:email),
         reply_to: @user.email,
         subject: "Nouveau message pour #{@house.name} du #{I18n.l @message.check_in, format: :long} - #{I18n.l @message.check_out, format: :long}",
         track_opens: 'true')
  end
end
