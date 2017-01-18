module Bot
  module DiscordCommands
    module User
      extend Discordrb::Commands::CommandContainer

      command(:user,
              description: 'shows you information about a user',
              usage: 'ccr username',
              min_args: 1) do |event, maybe_mode, *name|
        name = name.join ' '
        mode = maybe_mode.to_sym
        user   = OSU.user name, mode.to_sym if Osu::API::MODE.include? mode
        user ||= OSU.user maybe_mode + name
        next '`user not found`' unless user
        event.channel.send_embed(
          "`user info:` **#{user.name}**",
          Embeds.user_embed(user)
        )
      end
    end
  end
end
