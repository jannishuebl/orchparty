require 'byebug'

module Orcparty
  module Transformations
    class Mixin
      def transform(ast)
        ast.applications.transform_values! do |application|
          current = AST::Application.new
          application.mixins.each do |mixin_name|
            current = current.deep_merge_concat(ast.mixins[mixin_name])
          end
          transform_application(current.deep_merge_concat(application), ast)
        end
        ast
      end

      def transform_application(application, ast)
        application.services = application.services.transform_values! do |service|
          current = AST::Service.new
          service.delete(:mix).each do |mixin|
            mixin_name, mixin_service_name = mixin.split(".")
            current = current.deep_merge_concat(ast.mixins[mixin_name].services[mixin_service_name])
          end
          current.deep_merge_concat(service)
        end
        application
      end
    end
  end
end
