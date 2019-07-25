require 'orchparty'
require 'gli'

Orchparty.load_all_available_plugins

class OrchPartyApp
  extend GLI::App

  program_desc 'Write your orchestration configuration with a Ruby DSL that allows you to have mixins, imports and variables.'
  version Orchparty::VERSION

  subcommand_option_handling :normal

  desc "install kubernetes application"
  command :install do |com|
    com.flag [:cluster_name,:c,'cluster-name'], required: true, :desc => 'The cluster to install the app'
    com.flag [:filename,:f,'file-name'], required: true, :desc => 'The Orchparty input file'
    com.flag [:application,:a], required: true, :desc => 'The application that should be installed'
    com.switch :"force-variable-definition", :default_value => false, :desc => "Raises an Error if the input contains a not defined variable"
    com.action do |_, args|
      Orchparty.install(cluster_name: args[:c], application_name: args[:a], force_variable_definition: args["force-variable-definition"], file_name: args[:f])
    end
  end

  desc "upgrade kubernetes application"
  command :upgrade do |com|
    com.flag [:cluster_name,:c,'cluster-name'], required: true, :desc => 'The cluster to install the app'
    com.flag [:filename,:f,'file-name'], required: true, :desc => 'The Orchparty input file'
    com.flag [:application,:a], required: true, :desc => 'The application that should be installed'
    com.switch :"force-variable-definition", :default_value => false, :desc => "Raises an Error if the input contains a not defined variable"
    com.action do |_, args|
      Orchparty.upgrade(cluster_name: args[:c], application_name: args[:a], force_variable_definition: args["force-variable-definition"], file_name: args[:f])
    end
  end

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
