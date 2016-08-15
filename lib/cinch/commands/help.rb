require "cinch/commands/commands"

module Cinch
  module Commands
    #
    # Generic `!help` command that lists all commands.
    #
    class Help
      include Cinch::Commands

      command :help, [{ name: "COMMAND", format: :string, optional: true }],
              summary: "List all commands or displays help information for the"\
              " given COMMAND",
              description: "List all possible commands when supplied with no"\
              " arguments otherwise finds the specified COMMAND and prints the"\
              " usage and description."

      #
      # Displays a list of commands or the help information for a specific
      # command.
      #
      # @param [Cinch::Message]
      #   The message that invoked `!help`.
      #
      # @param [String] command
      #   The specific command to list help information for.
      #
      def help(m, command)
        if command
          found = commands_named(command)

          if found.empty?
            respond(m, "help: Unknown command #{command.dump}")
          else
            # print all usages
            found.each { |cmd| respond cmd.usage }

            # print the description of the first command
            respond(m, "")
            respond(m, found.first.description)
          end
        else
          each_command do |cmd|
            respond(m, "#{cmd.usage} - #{cmd.summary}")
          end
        end
      end

      # Send the response back to the user according to the config value
      # :help_response. It can be :notice to send back a notice to the user,
      # :send to query the user or :reply or nil to reply in the channel/query
      # it received the help request in.
      #
      # @param [Cinch::Message] m
      #   The message that invoked `!help`.
      #
      # @param [String] text
      #   The message to send back as a response.
      #
      def respond(m, text)
        case config[:help_response]
        when :notice
          m.user.notice text
        when :send
          m.user.send text
        else
          m.reply text
        end
      end

      protected

      # Enumerates over every command.
      #
      # @yield [command]
      #   The given block will be passed every command.
      #
      # @yieldparam [Command] command
      #   A command.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def each_command(&block)
        return enum_for(__method__) unless block_given?

        bot.config.plugins.plugins.each do |plugin|
          plugin.commands.each(&block) if plugin < Cinch::Commands
        end
      end

      #
      # Finds all commands with a similar name.
      #
      # @param [String] name
      #   The name to search for.
      #
      # @return [Array<Command>]
      #   The commands with the matching name.
      #
      def commands_named(name)
        each_command.select { |command| command.name == name }
      end
    end
  end
end
