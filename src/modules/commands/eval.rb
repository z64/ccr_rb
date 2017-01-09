module Bot
  module DiscordCommands
    # Command for evaluating Ruby code in an active bot.
    # Only the `event.user` with matching discord ID of `CONFIG.owner`
    # can use this command.
    module Eval
      extend Discordrb::Commands::CommandContainer
      command(:eval, help_available: false) do |event, *code|
        break unless event.user.id == CONFIG.owner
        begin
          eval code.join(' ')
        rescue => error
          event.channel.send_embed do |e|
            e.color = 0xff0000
            e.description = "```#{error}```"
            e.author = {
              name: 'An error occurred!',
              icon_url: 'http://emojipedia-us.s3.amazonaws.com/cache/f4/63/f463408675b9437b457915713b9af46c.png'
            }
          end
        end
      end
    end
  end
end
