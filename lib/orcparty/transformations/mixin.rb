require 'byebug'

module Orcparty
  module Transformations
    class Mixin
      def transform(ast)
        mixins = ast.mixins
        ast.applications = ast.applications.map do |name, application|
          current = AST::Application.new
          application.mixins.each do |mixin_name|
            current = current.deep_merge_concat(mixins[mixin_name])
          end
          [name, transform_application(current.deep_merge_concat(application), ast)]
        end.to_h
        ast
      end

      def transform_application(application, ast)
        application.services = application.services.map do |name, service|
          mix = service.delete(:mix)
          current = AST::Service.new
          mix.each do |mixin|
            mixin_name, mixin_service_name = mixin.split(".")
            current = current.deep_merge_concat(ast.mixins[mixin_name].services[mixin_service_name])
          end
          [name, current.deep_merge_concat(service)]
        end.to_h
        application
      end
    end
  end
end
