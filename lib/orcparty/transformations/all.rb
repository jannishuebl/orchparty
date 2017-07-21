
module Orcparty
  module Transformations
    class All
      def transform(ast)
        ast.applications = ast.applications.map do |name, application|
          application.services = application.services.map do |name, service|
            [name, AST::Service.new(application.all.deep_merge(service))]
          end.to_h
          [name, application]
        end.to_h
        ast
      end
    end
  end
end
