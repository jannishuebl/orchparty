
module Orcparty
  module Transformations
    class All
      def transform(ast)
        ast.applications = ast.applications.map do |application|
          application.services = application.services.map do |service|
            AST::Service.new application.all.deep_merge(service)
          end
          application
        end
        ast
      end
    end
  end
end
