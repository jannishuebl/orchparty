require 'byebug'

module Orcparty
  module Transformations
    class Mixin
      def transform_mixins(ast)
        ast.mixins.map {|mixin| [mixin.name, mixin.to_h]}.to_h
      end
      def transform(ast)
        mixins = transform_mixins(ast)
        ast.applications = ast.applications.map do |application|
          current = AST::Application.new
          application.mixins.each do |mixin_name|
            current = current.deep_merge(mixins[mixin_name])
          end
          current.deep_merge(application)
        end
        ast
      end
    end
  end
end
