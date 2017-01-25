module Bot
  module DiscordCommands
    module User
      extend Discordrb::Commands::CommandContainer

      command(Osu::API::MODE,
              description: 'shows you information about a user',
              usage: 'ccr.user [standard, ctb, taiko, mania] username',
              min_args: 1) do |event, *name|
        event.channel.start_typing
        name = name.join ' '
        mode = Osu::API::MODE.find { |sym| event.message.content.include? "ccr.#{sym}" }
        user   = OSU.user name, mode
        next '`user not found`' unless user
        event.channel.send_embed(
          "`user info:` **#{user.name}**",
          Embeds.user_embed(user)
        )
      end

      command(:events,
              description: 'shows you recent events on a user\'s profile',
              usage: 'ccr.events username',
              min_args: 1) do |event, *name|
        event.channel.start_typing
        name = name.join ' '
        user = OSU.user name, event_days: 7
        next '`user not found`' unless user
        next '`no events in the past week`' if user.events.empty?

        e = Discordrb::Webhooks::Embed.new(
          author: { name: 'View Profile', icon_url: Embeds::OSU_ICON },
          url: user.profile_url,
          footer: Embeds::VERSION_FOOTER,
          timestamp: Time.now,
          color: 0xFF69B4
        )

        events = user.events.take(10).map do |ev|
          html = ev.display_html
          html.gsub!('/b/', "#{Osu::API::BASE_URL}/b/")
          html.gsub! user.name, "️`#{ev.date.strftime('[%m-%d] %H:%M')}`"
          Upmark.convert html
        end

        e.description = events.join "\n\n"

        event.channel.send_embed "`recent events:` **#{user.name}**", e
      end

      command(:ranks,
              description: 'shows you ranks in each game mode',
              usage: 'ccr.ranks username',
              min_args: 1) do |event, *name|
        event.channel.start_typing
        name = name.join ' '
        stats = {}
        Osu::API::MODE.each do |mode|
          stats[mode] = OSU.user name, mode
          break if stats[mode].nil?
        end
        next '`user not found`' if stats.empty?
        stats.delete_if { |_, v| v.pp_rank.zero? }
        event.channel.send_embed(
          "`user ranks:` **#{stats.values.first.name}**",
          Embeds.ranks_embed(stats)
        )
      end
    end
  end
end
