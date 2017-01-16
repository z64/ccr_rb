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
        puts 'user link posted'
        urls = URI.extract event.message.content
        id = extract_id urls.find { |u| LINKS[:user] =~ u }

        user = OSU.user id

        next unless user

        event.channel.send_embed(
          "`user info:` **#{user.name}**",
          Embeds.user_embed(user)
        )
      end

      # Player profile link
      message(contains: LINKS[:beatmap]) do |event|
        puts 'beatmap link posted'
      end

      # Player profile link
      message(contains: LINKS[:beatmap_set]) do |event|
        puts 'beatmap_set link posted'
      end

      module_function

      def extract_id(url)
        url[/\d+/].to_i
      end
    end
  end
end
