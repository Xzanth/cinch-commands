module Cinch
  module Commands
    #
    # @api semipublic
    #
    class Command
      # Argument formats
      ARG_FORMATS = {
        string:  /\S+/,
        integer: /\d+/,
        float:   /\d*\.\d+/,
        text:    /.+/
      }.freeze

      # Name of the command
      attr_reader :name

      # Argument list
      attr_reader :arguments

      # Short summary of the command
      attr_reader :summary

      # Long description of the command
      attr_reader :description

      # Whether you need to be an operator to use
      attr_reader :op_command

      #
      # Creates a new command.
      #
      # @param [Symbol] name
      #   Name of the command.
      #
      # @param [Array<Hash>] arguments
      #   A list of argument hashes consisting of the names, formats and wether
      #   the argument is optional or not.
      #
      # @param [Hash] options
      #   Additional options.
      #
      # @option options [Array] :aliases
      #   Additiona aliases for the command.
      #
      # @option options [String] :summary
      #   Short summary of the command.
      #
      # @option options [String] :description
      #   Long description of the command.
      #
      def initialize(name, arguments, options = {})
        @name        = name.to_s
        @arguments   = arguments
        @aliases     = options.fetch(:aliases, []).map(&:to_s)

        @summary     = options[:summary]
        @description = options[:description]
        @op_command  = options[:op_command] || false
      end

      #
      # The names for the command.
      #
      # @return [Array<String>]
      #   Command names.
      #
      def names
        [@name] + @aliases
      end

      #
      # Creates a Regular Expression that matches invocations of the command.
      #
      # @return [Regexp]
      #   A Regular Expression that matches the command and captures it's
      #   arguments.
      #
      def regexp
        pattern = "(?:" + Regexp.union([@name] + @aliases).source + ")"

        @arguments.each do |arg|
          format = arg[:format]
          arg_regexp = case format
                       when Array  then Regexp.union(format)
                       when Regexp then format
                       when Symbol then ARG_FORMATS.fetch(format)
                       else             Regexp.escape(format.to_s)
                       end

          if arg[:optional]
            pattern << '(?:\s(' << arg_regexp.source << "))?"
          else
            pattern << " (" << arg_regexp.source << ")"
          end
        end

        # match the full message

        pattern << "$"

        Regexp.new(pattern)
      end

      #
      # The usage string for the command.
      #
      # @return [String]
      #   The usage string for the command and it's arguments.
      #
      def usage
        usage = "!#{@name}"

        @arguments.each do |arg|
          name = arg[:name]
          format = arg[:format]
          usage << " "
          use = case format
                when Array  then "[#{format.join('|')}]"
                when Regexp then format.source
                when Symbol then name.to_s.upcase
                else             format.to_s
                end
          usage << if arg[:optional]
                     "(#{use})"
                   else
                     use
                   end
        end
        usage
      end
    end
  end
end
