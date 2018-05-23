Slack.configure do |config|
  config.token = Rails.application.secrets.slack_token
end