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

      command(:ranks,
              description: 'shows you ranks in each game mode',
              usage: 'ccr.ranks username',
              min_args: 1) do |event, *name|
        name = name.join ' '
        stats = {}
        Osu::API::MODE.each do |mode|
          stats[mode] = OSU.user name, mode
          break if stats[mode].nil?
        end
        stats.compact!
        next '`user not found`' if stats.empty?
        event.channel.send_embed(
          "`user ranks:` **#{stats.values.first.name}**",
          Embeds.ranks_embed(stats)
        )
      end
    end
  end
end
