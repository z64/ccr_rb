module Bot
  module DiscordEvents
    module User
      extend Discordrb::EventContainer

      message(start_with: 'ccr ') do |event|
        name = event.message.content[4..-1]
        user = OSU.user name
        next event.respond '`user not found`' unless user
        event.channel.send_embed(
          "`user info:` **#{user.name}**",
          Embeds.user_embed(user)
        )
      end
    end
  end
end
