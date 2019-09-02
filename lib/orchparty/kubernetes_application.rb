require 'erb'
require 'erubis'
require 'open3'
require 'ostruct'
require 'byebug'
require 'yaml'
require 'tempfile'
require 'active_support'
require 'active_support/core_ext'


module Orchparty
  module Services

    class Context
      attr_accessor :cluster_name
      attr_accessor :namespace
      attr_accessor :dir_path
      attr_accessor :app_config

      def initialize(cluster_name: , namespace:, file_path: , app_config:)
        self.cluster_name = cluster_name
        self.namespace = namespace
        self.dir_path = file_path
        self.app_config = app_config
      end

      def template(file_path, helm, flag: "-f ", fix_file_path: nil)
        return "" unless file_path
        file_path = File.join(self.dir_path, file_path)
        if(file_path.end_with?(".erb"))
          helm.application = OpenStruct.new(cluster_name: cluster_name, namespace: namespace)
          template = Erubis::Eruby.new(File.read(file_path))
          yaml = template.result(helm.get_binding)
          file = Tempfile.new("kube-deploy.yaml")
          file.write(yaml)
          file.close
          file_path = file.path
        end
        "#{flag}#{fix_file_path || file_path}"
      end

      def print_install(helm)
        puts "---"
        puts install_cmd(helm, value_path(helm))
        puts "---"
        puts File.read(template(value_path(helm), helm, flag: "")) if value_path(helm)
      end

      def print_upgrade(helm)
        puts "---"
        puts install_cmd(helm, value_path(helm))
        puts "---"
        puts File.read(template(value_path(helm), helm, flag: "")) if value_path(helm)
      end


      def upgrade(helm)
        puts system(upgrade_cmd(helm))
      end


      def install(helm)
        puts system(install_cmd(helm))
      end
    end

    class Helm < Context

      def value_path(helm)
        helm[:values]
      end

      def upgrade_cmd(helm, fix_file_path = nil)
        "helm upgrade --namespace #{namespace} --kube-context #{cluster_name} --version #{helm.version} #{helm.name} #{helm.chart} #{template(value_path(helm), helm, fix_file_path: fix_file_path)}"
      end

      def install_cmd(helm, fix_file_path = nil)
        "helm install --namespace #{namespace} --kube-context #{cluster_name} --version #{helm.version} --name #{helm.name} #{helm.chart} #{template(value_path(helm), helm, fix_file_path: fix_file_path)}"
      end
    end

    class Apply < Context

      def value_path(apply)
        apply[:name]
      end

      def upgrade_cmd(apply, fix_file_path = nil)
        "kubectl apply --namespace #{namespace} --context #{cluster_name} #{template(value_path(apply), apply, fix_file_path: fix_file_path)}"
      end

      def install_cmd(apply, fix_file_path = nil)
        "kubectl apply --namespace #{namespace} --context #{cluster_name} #{template(value_path(apply), apply, fix_file_path: fix_file_path)}"
      end
    end

    class SecretGeneric < Context

      def value_path(secret)
        secret[:from_file]
      end

      def upgrade_cmd(secret, fix_file_path=nil)
        "kubectl --namespace #{namespace} --context #{cluster_name} create secret generic --dry-run -o yaml #{secret[:name]}  #{template(value_path(secret), secret, flag: "--from-file=", fix_file_path: fix_file_path)} | kubectl apply -f -"
      end

      def install_cmd(secret, fix_file_path=nil)
        "kubectl --namespace #{namespace} --context #{cluster_name} create secret generic --dry-run -o yaml #{secret[:name]}  #{template(value_path(secret), secret, flag: "--from-file=", fix_file_path: fix_file_path)} | kubectl apply -f -"
      end
    end

    class Label < Context

      def print_install(label)
        puts "---"
        puts install_cmd(label)
      end

      def print_upgrade(label)
        puts "---"
        puts upgrade_cmd(label)
      end

      def upgrade(label)
        puts system(upgrade_cmd(label))
      end

      def install(label)
        puts system(install_cmd(label))
      end

      def upgrade_cmd(label)
        "kubectl --namespace #{namespace} --context #{cluster_name} label --overwrite #{label[:resource]} #{label[:name]} #{label["value"]}"
      end

      def install_cmd(label)
        "kubectl --namespace #{namespace} --context #{cluster_name} label --overwrite #{label[:resource]} #{label[:name]} #{label["value"]}"
      end
    end

    class Wait < Context

      def print_install(wait)
        puts "---"
        puts wait.cmd
      end

      def print_upgrade(wait)
        puts "---"
        puts wait.cmd
      end

      def upgrade(wait)
        eval(wait.cmd)
      end

      def install(wait)
        eval(wait.cmd)
      end
    end

    class Chart < Context

      class CleanBinding
        def get_binding(params)
          params.instance_eval do
            binding
          end
        end
      end

      def build_chart(chart)
        params = chart._services.map {|s| app_config.services[s.to_sym] }.map{|s| [s.name, s]}.to_h
        Dir.mktmpdir do |dir|
          run(templates_path: File.join(self.dir_path, chart.template), params: params, output_chart_path: dir, chart: chart)
          yield dir
        end
      end


      def run(templates_path:, params:, output_chart_path:, chart: )

        system("mkdir -p #{output_chart_path}")
        system("mkdir -p #{File.join(output_chart_path, 'templates')}")

        system("cp #{File.join(templates_path, 'values.yaml')} #{File.join(output_chart_path, 'values.yaml')}")
        system("cp #{File.join(templates_path, '.helmignore')} #{File.join(output_chart_path, '.helmignore')}")
        system("cp #{File.join(templates_path, 'templates/_helpers.tpl')} #{File.join(output_chart_path, 'templates/_helpers.tpl')}")

        generate_chart_yaml(
          templates_path: templates_path,
          output_chart_path: output_chart_path,
          chart_name: chart.name,
        )

        params.each do |app_name, subparams|
          subparams[:chart] = chart
          generate_documents_from_erbs(
            templates_path: templates_path,
            app_name: app_name,
            params: subparams,
            output_chart_path: output_chart_path
          )
        end
      end

      def generate_documents_from_erbs(templates_path:, app_name:, params:, output_chart_path:)
        if params[:kind].nil?
          warn "ERROR: Could not generate service '#{app_name}'. Missing key: 'kind'."
          exit 1
        end

        kind = params.fetch(:kind)

        Dir[File.join(templates_path, kind, '*.erb')].each do |template_path|
          template_name = File.basename(template_path, '.erb')
          output_path = File.join(output_chart_path, 'templates', "#{app_name}-#{template_name}")

          template = Erubis::Eruby.new(File.read(template_path))
          params.app_name = app_name
          document = template.result(CleanBinding.new.get_binding(params))
          File.write(output_path, document)
        end
      end

      def generate_chart_yaml(templates_path:, output_chart_path:, chart_name: )
        template_path = File.join(templates_path, 'Chart.yaml.erb')
        output_path = File.join(output_chart_path, 'Chart.yaml')

        template = Erubis::Eruby.new(File.read(template_path))
        params = Hashie::Mash.new(chart_name: chart_name)
        document = template.result(CleanBinding.new.get_binding(params))
        File.write(output_path, document)
      end



      def print_install(chart)
        build_chart(chart) do |chart_path|
          puts `helm template --namespace #{namespace} --kube-context #{cluster_name} --name #{chart.name} #{chart_path}`
        end
      end

      def print_upgrade(chart)
        print_install(chart)
      end

      def install(chart)
        build_chart(chart) do |chart_path|
          puts system("helm install --namespace #{namespace} --kube-context #{cluster_name} --name #{chart.name} #{chart_path}")
        end
      end

      def upgrade(chart)
        build_chart(chart) do |chart_path|
          puts system("helm upgrade --namespace #{namespace} --kube-context #{cluster_name} #{chart.name} #{chart_path}")
        end
      end

    end
  end
end



class KubernetesApplication
  attr_accessor :cluster_name
  attr_accessor :file_path
  attr_accessor :namespace
  attr_accessor :app_config

  def initialize(app_config: [], namespace:, cluster_name:, file_name:)
    self.file_path = Pathname.new(file_name).parent.expand_path
    self.cluster_name = cluster_name
    self.namespace = namespace
    self.app_config = app_config
  end

  def install
    each_service(:install)
  end

  def upgrade
    each_service(:upgrade)
  end

  def print(method)
    each_service("print_#{method}".to_sym)
  end

  def combine_charts(app_config)
    services = app_config._service_order.map(&:to_s)
    app_config._service_order.each do |name|
      current_service = app_config[:services][name]
      if current_service._type == "chart"
        current_service._services.each do |n|
          services.delete n.to_s
        end
      end
    end
    services
  end

  def each_service(method)
    services = combine_charts(app_config)
    services.each do |name|
      service = app_config[:services][name]
      "::Orchparty::Services::#{service._type.classify}".constantize.new(cluster_name: cluster_name, namespace: namespace, file_path: file_path, app_config: app_config).send(method, service)
    end
  end

end

