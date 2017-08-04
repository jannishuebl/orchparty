require "simplecov"
SimpleCov.start
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchparty"


Orchparty.plugin :docker_compose_v1
Orchparty.plugin :docker_compose_v2

def sort_ast(ast)
  Orchparty::Transformations::Sort.new.transform(ast)
end
