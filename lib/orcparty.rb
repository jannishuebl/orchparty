require "orcparty/version"
require "orcparty/ast"
require "orcparty/transformations"
require "orcparty/generators"
require "orcparty/dsl_parser"
require "hash"

module Orcparty


  def self.ast(input_file)
    Transformations.transform(Orcparty::DSLParser.new(input_file).parse)
  end

  def self.docker_compose_v1(input_file)
    Orcparty::Generators::DockerComposeV1.new(ast(input_file)).output
  end

  def self.docker_compose_v2(input_file)
    Orcparty::Generators::DockerComposeV2.new(ast(input_file)).output
  end
end
