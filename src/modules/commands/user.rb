module Bot
  module DiscordCommands
    module User
      extend Discordrb::Commands::CommandContainer

      command(:user,
              description: 'shows you information about a user',
              usage: 'ccr username',
              min_args: 1) do |event, *name|
        name = name.join ' '
        user = OSU.user name
        next '`user not found`' unless user
        event.channel.send_embed(
          "`user info:` **#{user.name}**",
          Embeds.user_embed(user)
        )
      end
    end
  end
end
