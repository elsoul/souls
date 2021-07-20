module NotificationEngine
  def self.send_slack_error(message = "hoi!")
    Slack::Ruby3.push(webhook_url: ENV["SLACK"], message: message)
  end
end
