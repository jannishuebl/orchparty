
module Orchparty
  module Transformations
    class Variable
      def transform(ast)
        ast.applications.each do |_, application|
          application.services = application.services.each do |_, service|
            service.deep_transform_values! do |v|
              if v.respond_to?(:call)
                eval_value(build_context(application: application, service: service), v) 
              elsif v.is_a? Array
                v.map do |v|
                  if v.respond_to?(:call)
                    eval_value(build_context(application: application, service: service), v) 
                  else
                    v
                  end
                end
              else
                v
              end
            end
          end
        end
        ast
      end

      def eval_value(context, value)
        context.instance_exec(&value)
      end

      def build_context(application:, service:)
        application._variables ||= {}
        variables = application._variables.merge(service._variables)
        Context.new(variables.merge({application: application.merge(application._variables), service: service.merge(service._variables)}))
      end
    end
  end
end
