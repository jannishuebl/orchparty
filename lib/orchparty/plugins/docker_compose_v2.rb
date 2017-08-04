require 'yaml'
module Orchparty
  module Plugin
    module DockerComposeV2

      def self.desc
        "generate docker-compose v2 file"
      end

      def self.define_flags(c)
        c.flag [:output,:o], required: true, :desc => 'Set the output file'
      end

      def self.generate(ast, options)
        File.write(options[:output], output(ast))
      end

      def self.transform_to_yaml(hash)
        hash = hash.deep_transform_values{|v| v.is_a?(Hash) ? v.to_h : v }
        HashUtils.deep_stringify_keys(hash)
      end

      def self.output(application)
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

Orchparty::Plugin.register_plugin(:docker_compose_v2, Orchparty::Plugin::DockerComposeV2)
