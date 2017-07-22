
module Orcparty
  module Transformations
    class Variable
      def transform(ast)
        ast.applications = ast.applications.map do |name, application|
          application.services = application.services.map do |name, service|
            service.deep_transform_values! do |v|
              if v.respond_to?(:call)
                eval_value(build_context(application: application, service: service), v) 
              else
                v
              end
            end
            [name, service]
          end.to_h
          [name, application]
        end.to_h
        ast
      end

      def eval_value(context, value)
        context.instance_exec(&value)
      end

      def build_context(opts)
        Context.new(opts)
      end
    end
  end
end
