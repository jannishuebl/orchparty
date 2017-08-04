module Orchparty
  module Plugin
    class DockerComposeV1

      def self.desc
        "generate docker-compose v1 file"
      end

      def self.define_flags(c)
        c.flag [:output,:o], required: true, :desc => 'Set the output file'
      end

      def self.generate(ast, options)
        File.write(options[:output], output(ast))
      end

      def self.output(ast)
        ast.services.map do |name, service|
          service = service.to_h
          service.delete(:mix)
          [service.delete(:name), HashUtils.deep_stringify_keys(service.to_h)]
        end.to_h.to_yaml
      end

    end
  end
end

Orchparty::Plugin.register_plugin(:docker_compose_v1, Orchparty::Plugin::DockerComposeV1)