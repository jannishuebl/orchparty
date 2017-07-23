
module Orchparty
  module Transformations
    class RemoveInternal
      def transform(ast)
        ast.applications.each do |_, application|
          application.delete_if {|k, _| k.to_s.start_with?("_")}
          application.services = application.services.each do |_, service|
            service.delete_if {|k, _| k.to_s.start_with?("_")}
          end
        end
        ast
      end
    end
  end
end
