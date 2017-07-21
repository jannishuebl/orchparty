require 'byebug'

module Orcparty
  module Transformations
    class Mixin
      def transform(ast)
        mixins = ast.mixins
        ast.applications = ast.applications.map do |name, application|
          current = AST::Application.new
          application.mixins.each do |mixin_name|
            current = current.deep_merge(mixins[mixin_name])
          end
          [name, current.deep_merge(application)]
        end.to_h
        ast
      end
    end
  end
end
