module Orchparty
  module Transformations
    class Variable

      def initialize(opts = {})
        @force_variable_definition = opts[:force_variable_definition]
      end

      def transform(ast)
        ast.applications.each do |_, application|
          app_variables = application._variables || {}
          app_variables = app_variables.merge({application: application.merge(application._variables)})
          application.services = application.services.each do |_, service|
            resolve(app_variables, service, service)
          end
          application.volumes = application.volumes.each do |_, volume|
            resolve(app_variables, volume, nil) if volume
          end
        end
        ast
      end

      def resolve(app_variables, subject, service)
        context = build_context(app_variables, service)
        subject.deep_transform_values! do |v|
          if v.respond_to?(:call)
            eval_value(context, v) 
          elsif v.is_a? Array
            v.map do |v|
              if v.respond_to?(:call)
                eval_value(context, v) 
              else
                v
              end
            end
          else
            v
          end
        end
      end

      def eval_value(context, value)
        context.instance_exec(&value)
      end

      def build_context(variables, service)
        if service
          variables = variables.merge(service._variables)
          variables[:service] = service.merge(service._variables)
        end
        context = Context.new(variables)
        context._force_variable_definition = @force_variable_definition
        context
      end
    end
  end
end
