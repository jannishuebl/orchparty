module Orchparty
  module Transformations
    class Mixin
      def transform(ast)
        ast.applications.transform_values! do |application|
          current = AST.application
          application._mix.each do |mixin_name|
            mixin = application._mixins[mixin_name] || ast._mixins[mixin_name]
            current = current.deep_merge_concat(mixin)
          end
          transform_application(current.deep_merge_concat(application), ast)
        end
        ast
      end

      def transform_application(application, ast)
        application.services = application.services.transform_values! do |service|
          current = AST.service
          service.delete(:_mix).each do |mix|
            mixin = transform_mixin(resolve_mixin(mix, application, ast), application, ast)
            current = current.deep_merge_concat(mixin)
          end
          current.deep_merge_concat(service)
        end
        application
      end

      def resolve_mixin(mix, application, ast)
        if mix.include? "."
          mixin_name, mixin_service_name = mix.split(".")
          ast._mixins[mixin_name]._mixins[mixin_service_name]
        else
          application._mixins[mix]
        end
      end

      def transform_mixin(mixin, application, ast)
        current = AST.application_mixin
        mixin[:_mix].each do |mix|
          current = current.deep_merge_concat(resolve_mixin(mix, application, ast))
        end
        current.deep_merge_concat(mixin)
      end
    end
  end
end
