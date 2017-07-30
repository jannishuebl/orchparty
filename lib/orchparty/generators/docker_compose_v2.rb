require 'yaml'
module Orchparty
  module Generators
    class DockerComposeV2
      attr_reader :ast
      def initialize(ast)
        @ast = ast
      end

      def transform_to_yaml(hash)
        hash = hash.deep_transform_values{|v| v.is_a?(Hash) ? v.to_h : v }
        HashUtils.deep_stringify_keys(hash)
      end

      def output(application_name)
        application = ast.applications[application_name]
        {"version" => "2", 
         "services" =>
        application.services.map do |name,service|
           service = service.to_h
           [service.delete(:name), HashUtils.deep_stringify_keys(service.to_h)]
         end.to_h,
         "volumes" => transform_to_yaml(application.volumes),
         "networks" => transform_to_yaml(application.networks),
        }.to_yaml
      end

    end
  end
end
