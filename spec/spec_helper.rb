require "simplecov"
SimpleCov.start
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchparty"

def sort_ast(ast)
  Orchparty::Transformations::Sort.new.transform(ast)
end
