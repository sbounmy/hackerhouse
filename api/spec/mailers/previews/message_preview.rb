# Preview all emails at http://localhost:3000/rails/mailers/balance
class MessagePreview < ActionMailer::Preview
  def create
    MessageMailer.create_email(Message.first)
  end
end
