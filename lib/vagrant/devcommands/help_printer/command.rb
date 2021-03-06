module VagrantPlugins
  module DevCommands
    module HelpPrinter
      # Prints help for a command
      class Command
        UTIL     = VagrantPlugins::DevCommands::Util
        MESSAGES = VagrantPlugins::DevCommands::Messages

        def initialize(env)
          @env = env
        end

        def output(command)
          header(command)
          arguments(command.parameters, 'Parameters')
          arguments(command.flags, 'Flags')
          body(command.help)
        end

        private

        def arguments(arguments, title)
          return if arguments.nil?

          info("#{title}:", true)
          arguments_body(arguments)
        end

        def arguments_body(arguments)
          pad_to = UTIL.pad_to(arguments)

          arguments.sort.each do |name, options|
            info(UTIL.padded_columns(pad_to, name, options[:desc]))
          end
        end

        def body(help)
          return message(:command_no_help, true) if help.nil?

          info(help.strip, true)
        end

        def header(command)
          usage = "vagrant run [box] #{command.name}"
          usage = usage_params(usage, command)

          unless command.usage.nil?
            usage = format(command.usage, command: command)
          end

          info(I18n.t('vagrant_devcommands.internal.help.usage', what: usage))
        end

        def info(msg, pre_ln = false)
          @env.ui.info '' if pre_ln
          @env.ui.info msg
        end

        def message(msg, pre_ln = false)
          if pre_ln
            MESSAGES.pre_ln(msg, &@env.ui.method(:info))
          else
            MESSAGES.public_send(msg, &@env.ui.method(:info))
          end
        end

        def usage_params(usage, command)
          [
            usage,
            UTIL.collect_mandatory_params(command.parameters || {}),
            UTIL.collect_optional_params(command.parameters || {}),
            UTIL.collect_flags(command.flags || {})
          ].flatten.compact.join(' ').strip
        end
      end
    end
  end
end
