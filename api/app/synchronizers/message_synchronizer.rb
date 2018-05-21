class MessageSynchronizer < ApplicationSynchronizer
  def create_mailer
    MessageMailer.with(message: params[:message]).create_email.deliver
  end
end