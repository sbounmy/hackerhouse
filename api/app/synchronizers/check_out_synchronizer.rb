class CheckOutSynchronizer < ApplicationSynchronizer
  on :remind do
    to :mailer do
      UserMailer.with(user: params[:user]).check_out_reminder_email.deliver
    end

    to :slack do
      user = params[:user]
      App.slack.chat_postMessage(
        channel: user.house.slack_id,
        text: "D#{d_check_out(user)}: Départ de #{user.firstname}, avez-vous trouvé un nouveau coloc ? @channel",
        as_user: true)
    end

  end

  private
  # Returns an integer which is the number of days before check out
  def d_check_out(user)
    (Time.zone.now.to_i - user.check_out.to_time.to_i) / 1.day
  end

end