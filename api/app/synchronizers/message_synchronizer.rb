class MessageSynchronizer < ApplicationSynchronizer
  on :create do
    to :mailer do
      MessageMailer.with(message: params[:message]).create_email.deliver
    end
  end
end