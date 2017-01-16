require 'upmark'

# We extend Integer for pretty-printing large numbers
class Integer
  def to_cspv
    self.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  end
end

module Bot
  module Embeds
    module_function

    # Embed for a Osu::User
    def user_embed(user)
      e = Discordrb::Webhooks::Embed.new(
        author: { name: 'View Profile', icon_url: 'http://vignette2.wikia.nocookie.net/fantendo/images/1/12/Osu!_logo.png' },
        url: user.profile_url,
        footer: { text: "osu-api v#{Osu::VERSION}" },
        timestamp: Time.now,
        color: 0xFF69B4
      )

      e.add_field(
        name: 'Ranks',
        value: <<~data
          **PP Rank:** #{user.pp_rank.to_cspv} (`#{user.pp_raw.round(2)}`) / **Country (#{user.country}):** #{user.pp_country_rank.to_cspv}
          **SS** `x#{user.count_rank[:ss]}` / **S** `x#{user.count_rank[:s]}` / **A** `x#{user.count_rank[:a]}`
        data
      )

      e.add_field(
        name: 'Hits',
        value: <<~data
          **Accuracy:** `#{user.accuracy.round(2)}%`
          300 `x#{user.count300.to_cspv}` / 100 `x#{user.count100.to_cspv}` / 50 `x#{user.count50.to_cspv}`
        data
      )

      e.add_field(
        name: 'Score',
        value: <<~data
          **Level #{user.level.round(2)}**
          **Total:** #{user.total_score.to_cspv} / **Ranked:** #{user.ranked_score.to_cspv}
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
