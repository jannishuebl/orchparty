require "deep_merge"
require "orchparty/version"
require "orchparty/ast"
require "orchparty/context"
require "orchparty/transformations"
require "orchparty/generators"
require "orchparty/dsl_parser"
require "hash"

module Orchparty


  def self.ast(input_file)
    Transformations.transform(Orchparty::DSLParser.new(input_file).parse)
  end

  def self.docker_compose_v1(input_file, application_name)
    Orchparty::Generators::DockerComposeV1.new(ast(input_file)).output(application_name)
  end

  def self.docker_compose_v2(input_file, application_name)
    Orchparty::Generators::DockerComposeV2.new(ast(input_file)).output(application_name)
  end
end
