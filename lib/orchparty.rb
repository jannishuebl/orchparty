require "deep_merge"
require "orchparty/version"
require "orchparty/ast"
require "orchparty/context"
require "orchparty/transformations"
require "orchparty/dsl_parser"
require "orchparty/plugin"
require "hash"

module Orchparty

  def self.load_all_available_plugins
    Gem::Specification.map {|f| f.matches_for_glob("orchparty/plugins/*.rb") }.flatten.map{|file_name| File.basename(file_name, ".*").to_sym }.each do |plugin_name|
      plugin(plugin_name)
    end
  end

  def self.plugins
    Orchparty::Plugin.plugins
  end

  def self.plugin(name)
    Orchparty::Plugin.load_plugin(name)
  end

  def self.ast(filename: , application:, force_variable_definition: nil )
    Transformations.transform(Orchparty::DSLParser.new(filename).parse, force_variable_definition: force_variable_definition).applications[application]
  end

  def self.generate(plugin_name, options, plugin_options)
    plugins[plugin_name].generate(ast(options), plugin_options)
  end
end
