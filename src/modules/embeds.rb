require 'upmark'

# We extend Integer for pretty-printing large numbers
class Integer
  def to_cspv
    self.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  end
end

module Bot
  module Embeds
    # the Osu! logo
    OSU_ICON = 'http://vignette2.wikia.nocookie.net/fantendo/images/1/12/Osu!_logo.png'
    VERSION_FOOTER = Discordrb::Webhooks::EmbedFooter.new text: "osu-api v#{Osu::VERSION}"
    STAR_EMOJI = "\u2B50"

    module_function

    # Embed for a Osu::User
    def user_embed(user)
      e = Discordrb::Webhooks::Embed.new(
        author: { name: 'View Profile', icon_url: OSU_ICON },
        url: user.profile_url,
        footer: VERSION_FOOTER,
        timestamp: Time.now,
        color: 0xFF69B4,
        description: "Stats for game mode: `#{user.mode}`"
      )

      e.add_field(
        name: 'Stats',
        value: <<~data
          **PP Rank:** #{user.pp_rank.to_cspv} (`#{user.pp_raw.round(2)}`) / **Country (#{user.country}):** #{user.pp_country_rank.to_cspv}
          **SS** `x#{user.count_rank[:ss]}` / **S** `x#{user.count_rank[:s]}` / **A** `x#{user.count_rank[:a]}`

          **Accuracy:** `#{user.accuracy.round(2)}%`
          300 `x#{user.count300.to_cspv}` / 100 `x#{user.count100.to_cspv}` / 50 `x#{user.count50.to_cspv}`

          **Level #{user.level.round(2)}**
          **Total Score:** #{user.total_score.to_cspv} / **Ranked:** #{user.ranked_score.to_cspv}
        data
      )

      score = OSU.user_score(user.name, mode: user.mode)&.first
      beatmap = OSU.beatmap(score.beatmap_id) if score

      if score && beatmap
        e.add_field score_field("Best #{user.mode.capitalize} Score", beatmap, score)
      end

      e
    end

    def score_field(name = "\u200B", beatmap, score, user: nil)
      data = <<~data
        **[#{beatmap.artist} - #{beatmap.title} (#{beatmap.version})](#{beatmap.url})**
        Rank: ***#{score.rank}*** / Combo: **#{score.max_combo}** (max: #{beatmap.max_combo}) / `#{score.pp} PP`
        Score: `#{score.score.to_cspv}`
        Mods: #{score.mods(true).join(', ')}
      data

      data += "[[View Profile]](#{user.profile_url})" if user

      Discordrb::Webhooks::EmbedField.new(name: name, value: data)
    end

    def ranks_embed(stats)
      e = Discordrb::Webhooks::Embed.new(
        author: { name: 'View Profile', icon_url: OSU_ICON },
        url: stats.values.first.profile_url,
        footer: VERSION_FOOTER,
        timestamp: Time.now,
        color: 0xFF69B4
      )

      data = stats.keys.map do |mode|
        user = stats[mode]
        "**#{mode}:** #{user.pp_rank.to_cspv} (`#{user.pp_raw.round(2)}`)"
      end.join("\n")

      e.description = data

      e
    end

    def beatmap_embed(beatmap)
      e = Discordrb::Webhooks::Embed.new(
        author: { name: 'View Beatmap', icon_url: OSU_ICON },
        url: beatmap.url,
        footer: VERSION_FOOTER,
        timestamp: Time.now,
        color: 0xFF69B4,
        description: <<~data
          Mapped by: **#{beatmap.creator}** `[#{beatmap.mode} | #{beatmap.approval}]`
        data
      )

      e.add_field(
        name: 'Difficulty',
        inline: true,
        value: <<~data
          Overall: **#{beatmap.difficulty[:overall]}**
          Star Difficulty: **#{beatmap.difficulty[:rating].round(2)}**
          Circle Size: **#{beatmap.difficulty[:size]}**
          HP Drain: **#{beatmap.difficulty[:drain]}**
          Approach Rate: **#{beatmap.difficulty[:approach]}**
        data
      )

      total_length = Time.at(beatmap.total_length).strftime "%M:%S"
      hit_length = Time.at(beatmap.hit_length).strftime "%M:%S"

      e.add_field(
        name: 'Stats',
        inline: true,
        value: <<~data
          Length: `#{total_length}` (`#{hit_length}` drain) @ #{beatmap.bpm} BPM
          Max Combo: **#{beatmap.max_combo}**
          Pass Count: **#{beatmap.pass_count.to_cspv} / #{beatmap.play_count.to_cspv}** (#{(beatmap.pass_count.to_f / beatmap.play_count.to_f).round(2)}%)
          Favorited by **#{beatmap.favourite_count.to_cspv}** players
        data
      )

      score = OSU.beatmap_score(beatmap.id, mode: beatmap.mode)&.first
      user = OSU.user(score.username)

      if score && user
        e.add_field score_field("Top Score [#{user.name}]", beatmap, score, user: user)
      end

      # if beatmap.tags
      #  e.add_field(
      #    name: 'Tags',
      #    value: beatmap.tags.split(' ').map { |t| "`#{t}`" }.join(' ')
      #  )
      # end

      e
    end

    def beatmap_set_embed(set)
      e = Discordrb::Webhooks::Embed.new(
        author: { name: 'View Beatmap Set', icon_url: OSU_ICON },
        url: set.url,
        footer: VERSION_FOOTER,
        timestamp: Time.now,
        color: 0xFF69B4,
        description: <<~data
          Mapped by: **#{set.creator}** `[#{set.mode} | #{set.approval}]`
        data
      )

      map_strings = set.maps.map do |m|
        length = Time.at(m.total_length).strftime "%M:%S"
        "▫️[#{m.version}](#{m.url}) (diff: **#{m.difficulty[:overall]}** / combo: **#{m.max_combo}** / `#{length}`)"
      end

      e.add_field(
        name: 'Maps in this set',
        value: map_strings.join("\n")
      )

      e
    end
  end
end
