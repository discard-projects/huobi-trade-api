# $slack_bug_notifier = Slack::Notifier.new $env[:slack_webhook_url] do
#   defaults channel: "#huobi-notifier",
#            username: "notifier"
# end
$slack_bug_notifier = Slack::Notifier.new $env[:slack_webhook_url] do
  defaults channel: "#huobi-bugs",
           username: "sidekiq"
end