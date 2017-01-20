module Bot
  module DiscordEvents
    # Collection of events associated with detecting
    # Osu links posted in Discord
    module Links
      extend Discordrb::EventContainer

      # Regex for matching Osu urls in chat
      LINKS = {
        user:        /#{Osu::API::BASE_URL}\/u\/\d+/,
        beatmap:     /#{Osu::API::BASE_URL}\/b\/\d+/,
        beatmap_set: /#{Osu::API::BASE_URL}\/s\/\d+/
      }

      # Player profile link
      message(contains: LINKS[:user]) do |event|
        urls = URI.extract event.message.content
        id = extract_id urls.find { |u| LINKS[:user] =~ u }

        user = OSU.user id

        next unless user

        event.channel.send_embed(
          "`user info:` **#{user.name}**",
          Embeds.user_embed(user)
        )
      end

      # Beatmap link
      message(contains: LINKS[:beatmap]) do |event|
        urls = URI.extract event.message.content
        id = extract_id urls.find { |u| LINKS[:beatmap] =~ u }

        beatmap = OSU.beatmap id

        next unless beatmap

        event.channel.send_embed(
          "`beatmap info:` **#{beatmap.artist} - #{beatmap.title}** (#{beatmap.version})",
          Embeds.beatmap_embed(beatmap)
        )
      end

      # Beatmap set link
      message(contains: LINKS[:beatmap_set]) do |event|
        urls = URI.extract event.message.content
        id = extract_id urls.find { |u| LINKS[:beatmap_set] =~ u }

        set = OSU.beatmap_set id

        next unless set

        event.channel.send_embed(
          "`beatmap set info:` **#{set.artist} - #{set.title}**",
          Embeds.beatmap_set_embed(set)
        )
      end

      module_function

      def extract_id(url)
        url[/\d+/].to_i
      end
    end
  end
end
