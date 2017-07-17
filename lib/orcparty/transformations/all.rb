require 'deep_merge'

module Orcparty
  module Transformations
    class All
      def transform(ast)
        ast.services = ast.services.map do |service|
          AST::Service.new service.to_h.deep_merge(ast.all.to_h)
        end
        ast
      end
    end
  end
end
