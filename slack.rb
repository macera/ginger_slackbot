require 'slack'
require './lib/ginger'
require 'dotenv'

Dotenv.load

Slack.configure {|config| config.token = ENV["BOT_TOKEN"] }
client = Slack.realtime

client.on :hello do
  puts 'Successfully connected.'
end

client.on :message do |data|

  if data['text'] =~ /\Acheck:/ && data['subtype'] != 'bot_message'
    text = data['text']
    text.slice!('check:')
    result = Ginger.check(text.strip)
    params = {
      token: ENV["BOT_TOKEN"],
      channel: data['channel'],
      text: "<@#{data['user']}> #{result}",
    }
    Slack.chat_postMessage params
  end

end

client.start
