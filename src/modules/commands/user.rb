module Bot
  module DiscordCommands
    module User
      extend Discordrb::Commands::CommandContainer

      command(Osu::API::MODE,
              description: 'shows you information about a user',
              usage: 'ccr.user [standard, ctb, taiko, mania] username',
              min_args: 1) do |event, *name|
        name = name.join ' '
        mode = Osu::API::MODE.find { |sym| event.message.content.include? "ccr.#{sym}" }
        user   = OSU.user name, mode
        next '`user not found`' unless user
        event.channel.send_embed(
          "`user info:` **#{user.name}**",
          Embeds.user_embed(user)
        )
      end
    end
  end
end
