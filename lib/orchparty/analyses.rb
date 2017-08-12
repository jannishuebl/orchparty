require 'byebug'

module Orchparty
  module Analyses
    class ListMissingVariables
      def analyse(ast)
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
        @missing
      end

      def eval_value(context, value)
        context.instance_exec(&value)
        @missing ||= {}
        if context._missing
          m = context._missing
          @missing[m[:app]] ||= {}
          @missing[m[:app]][m[:service]] ||= []
          @missing[m[:app]][m[:service]] << m[:var]
        end
      end

      def build_context(application:, service:)
        application._variables ||= {}
        variables = application._variables.merge(service._variables)
        Context.new(variables.merge({application: application.merge(application._variables), service: service.merge(service._variables)}))
      end

      class Context < ::Hashie::Mash
        include Hashie::Extensions::DeepMerge
        include Hashie::Extensions::DeepMergeConcat
        include Hashie::Extensions::MethodAccess
        include Hashie::Extensions::Mash::KeepOriginalKeys

        def initialize(*args)
          super
        end

        def _missing
          @_missing
        end


        def method_missing(name, *args)
          if  !key?(name)  && !key?(name.to_s)
            @_missing = {app: application.name, service: service.name, var:  name.to_sym}
          end
          super
        end

        def context
          self
        end
      end
    end

    def self.list_missing_variables(ast)
      ast = Transformations::All.new.transform(ast)
      ast = Transformations::Mixin.new.transform(ast)
      ListMissingVariables.new.analyse(ast)
    end
  end
end