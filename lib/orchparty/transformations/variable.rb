module Orchparty
  module Transformations
    class Variable

      def initialize(opts = {})
        @force_variable_definition = opts[:force_variable_definition]
      end

      def transform(ast)
        ast.applications.each do |_, application|
          application.services = application.services.each do |_, service|
            resolve(application, service, service)
          end
          application.volumes = application.volumes.each do |_, volume|
            resolve(application, volume, nil) if volume
          end
        end
        ast
      end

      def resolve(application, subject, service)
        subject.deep_transform_values! do |v|
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

      def eval_value(context, value)
        context.instance_exec(&value)
      end

      def build_context(application:, service:)
        variables = application._variables || {}
        variables = variables.merge({application: application.merge(application._variables)})
        if service
          variables = variables.merge(service._variables)
          variables = variables.merge({service: service.merge(service._variables)})
        end
        context = Context.new(variables)
        context._force_variable_definition = @force_variable_definition
        context
      end
    end
  end
end
