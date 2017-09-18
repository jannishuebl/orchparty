require 'yaml'
module Orchparty
  module Plugin
    module DockerComposeV2

      def self.desc
        "generate docker-compose v2 file"
      end

      def self.define_flags(c)
        c.flag [:output,:o], :desc => 'Set the output file'
      end

      def self.generate(ast, options)
        output = output(ast)
        if options[:output]
          File.write(options[:output], output)
        else
          puts output
        end
      end

      def self.transform_to_yaml(hash)
        hash = hash.deep_transform_values{|v| v.is_a?(Hash) ? v.to_h : v }
        HashUtils.deep_stringify_keys(hash)
      end

      def self.output(application)
        output_hash = {"version" => "2", 
         "services" =>
        application.services.map do |name,service|
           service = service.to_h
           [service.delete(:name), HashUtils.deep_stringify_keys(service.to_h)]
         end.to_h,
        }
        output_hash["volumes"] = transform_to_yaml(application.volumes) if application.volumes && !application.volumes.empty?
        output_hash["networks"] = transform_to_yaml(application.networks) if application.networks && !application.networks.empty?
        output_hash.to_yaml(line_width: -1)
      end
    end
  end
end

Orchparty::Plugin.register_plugin(:docker_compose_v2, Orchparty::Plugin::DockerComposeV2)
