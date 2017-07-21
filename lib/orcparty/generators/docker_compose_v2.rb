require 'yaml'
module Orcparty
  module Generators
    class DockerComposeV2
      attr_reader :ast
      def initialize(ast)
        @ast = ast
      end

      def output(application_name)
        {"version" => "2", 
         "services" =>
        ast.applications[application_name].services.map do |name,service|
           service = service.to_h
           [service.delete(:name), HashUtils.deep_stringify_keys(service.to_h)]
         end.to_h
        }.to_yaml
      end

    end
  end
end
