require 'orchparty'
require 'gli'

Orchparty.load_all_available_plugins

class OrchPartyApp
  extend GLI::App

  program_desc 'Write your orchestration configuration with a Ruby DSL that allows you to have mixins, imports and variables.'
  version Orchparty::VERSION

  subcommand_option_handling :normal

  desc "Compiles a Orchparty input file to a orchestration framework configuration"
  command :generate do |com|
    Orchparty.plugins.each do |name, plugin|
        com.desc plugin.desc
        com.command(name) do |plugin_command|
          plugin_command.flag [:filename,:f,'file-name'], required: true, :desc => 'The Orchparty input file'
          plugin_command.flag [:application,:a], required: true, :desc => 'The application that should be compiled'
          plugin_command.switch :"force-variable-definition", :default_value => false, :desc => "Raises an Error if the input contains a not defined variable"
          plugin.define_flags(plugin_command)
          plugin_command.action do |global_options,plugin_options,args|
            options = plugin_options.delete(GLI::Command::PARENT)
            options[:application] = plugin_options[:application]
            options[:filename] = plugin_options[:filename]
            options[:force_variable_definition] = plugin_options[:"force-variable-definition"]
            Orchparty.generate(name, options, plugin_options)
          end
        end
    end
  end
end

exit OrchPartyApp.run(ARGV)
