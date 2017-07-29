
module Orchparty
  module Transformations
    class All
      def transform(ast)
        ast.applications.each do |_, application|
          application.services.transform_values! do |service|
            if application.all.is_a?(Hash)
              AST::Service.new(application.all.deep_merge_concat(service)) 
            else
              service
            end
          end
        end
        ast
      end
    end
  end
end
