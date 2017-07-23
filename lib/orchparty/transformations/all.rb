
module Orchparty
  module Transformations
    class All
      def transform(ast)
        ast.applications.each do |_, application|
          application.services.transform_values! do |service|
             AST::Service.new(application.all.deep_merge(service))
          end
        end
        ast
      end
    end
  end
end
