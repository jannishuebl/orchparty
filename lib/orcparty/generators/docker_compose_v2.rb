require 'yaml'
module Orcparty
  module Generators
    class DockerComposeV2
      attr_reader :ast
      def initialize(ast)
        @ast = ast
      end

      def output
        {"version" => "2", 
         "services" =>
         ast.services.map do |service|
           service = service.to_h
           [service.delete(:name), HashUtils.deep_stringify_keys(service.to_h)]
         end.to_h
        }.to_yaml
      end

    end
  end
end
