module Bot
  module DiscordEvents
    module User
      extend Discordrb::EventContainer

      message(start_with: 'ccr ') do |event|
        name = event.message.content[4..-1]
        BOT.execute_command(
          :user,
          Discordrb::Commands::CommandEvent.new(event.message, BOT),
          name
        )
      end
    end
  end
end
