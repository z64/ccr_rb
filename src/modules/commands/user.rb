require 'upmark'

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
        next 'user not found' unless user
        event.channel.send_embed(
          "`user info:` **#{user.name}**",
          user_embed(user)
        )
      end

      module_function

      def user_embed(user)
        e = Discordrb::Webhooks::Embed.new(
          title: '[View Profile]',
          url: user.profile_url,
          footer: { text: "osu-api v#{Osu::VERSION}" },
          timestamp: Time.now,
          color: 0xFF69B4
        )

        e.add_field(
          name: 'Ranks',
          inline: true,
          value: <<~data
            **PP Rank:** #{user.pp_rank} (`#{user.pp_raw.round(2)}`) / **Country (#{user.country}):** #{user.pp_country_rank}
            **SS** `x#{user.count_rank[:ss]}` / **S** `x#{user.count_rank[:s]}` / **A** `x#{user.count_rank[:a]}`
            **Level #{user.level.round(2)}**
          data
        )

        e.add_field(
          name: 'Hits',
          inline: true,
          value: <<~data
            **Accuracy:** `#{user.accuracy.round(2)}%`
            300 `x#{user.count300}` / 100 `x#{user.count100}` / 50 `x#{user.count50}`
          data
        )

        e.add_field(
          name: 'Score',
          inline: true,
          value: <<~data
            **Total:** #{user.total_score}
            **Ranked:** #{user.ranked_score}
          data
        )

        if user.events.any?
          events = user.events.map do |ev|
            html = ev.display_html
            html.gsub!(/\/b\/\d+/) { |m| "#{Osu::API::BASE_URL}/#{m}" }
            html.gsub! user.name, "▫️️`#{ev.date}`"
            Upmark.convert html
          end
          e.add_field(
            name: 'Events',
            value: events.join("\n")
          )
        end

        e
      end
    end
  end
end
