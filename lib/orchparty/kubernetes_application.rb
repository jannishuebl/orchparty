require 'erb'
require 'open3'
require 'ostruct'
require 'byebug'
require 'yaml'
require 'tempfile'
require 'active_support'
require 'active_support/core_ext'



class Context
  attr_accessor :cluster_name
  attr_accessor :namespace
  attr_accessor :dir_path

  def initialize(cluster_name: , namespace:, file_path: )
    self.cluster_name = cluster_name
    self.namespace = namespace
    self.dir_path = file_path
  end

  def template(file_path, helm, flag = "-f ")
    return "" unless file_path
    file_path = File.join(self.dir_path, file_path)
    if(file_path.end_with?(".erb"))
      helm.application = OpenStruct.new(cluster_name: cluster_name, namespace: namespace)
      template = ERB.new File.read(file_path )
      yaml = template.result(helm.get_binding)
      file = Tempfile.new("kube-deploy.yaml")
      file.write(yaml)
      file.close
      file_path = file.path
    end
    "#{flag}#{file_path}"
  end

  def upgrade(helm)
    puts `helm upgrade --namespace #{namespace} --kube-context #{cluster_name} --version #{helm.version} #{helm.name} #{helm.chart} #{template(helm[:values], helm)}`
  end

  def install(helm)
    puts `helm install --namespace #{namespace} --kube-context #{cluster_name} --version #{helm.version} --name #{helm.name} #{helm.chart} #{template(helm[:values], helm)}`
  end
end

class Helm < Context
  def upgrade(helm)
    puts `helm upgrade --namespace #{namespace} --kube-context #{cluster_name} --version #{helm.version} #{helm.name} #{helm.chart} #{template(helm[:values], helm)}`
  end

  def install(helm)
    puts `helm install --namespace #{namespace} --kube-context #{cluster_name} --version #{helm.version} --name #{helm.name} #{helm.chart} #{template(helm[:values], helm)}`
  end
end

class Apply < Context
  def upgrade(apply)
    puts `kubectl apply --namespace #{namespace} --context #{cluster_name} #{template(apply[:name], apply)}`
  end

  def install(apply)
    puts `kubectl apply --namespace #{namespace} --context #{cluster_name} #{template(apply[:name], apply)}`
  end
end

class SecretGeneric < Context
  def upgrade(secret)
    puts `kubectl --namespace #{namespace} --context #{cluster_name} create secret generic --dry-run -o yaml #{secret[:name]}  #{template(secret[:from_file], secret, "--from-file=")} | kubectl apply -f -`
  end

  def install(secret)
    puts `kubectl --namespace #{namespace} --context #{cluster_name} create secret generic --dry-run -o yaml #{secret[:name]}  #{template(secret[:from_file], secret, "--from-file=")} | kubectl apply -f -`
  end
end

class Label < Context
  def upgrade(label)
    puts `kubectl --namespace #{namespace} --context #{cluster_name} label --overwrite #{label[:resource]} #{label[:name]} #{label["value"]}`
  end

  def install(label)
    puts `kubectl --namespace #{namespace} --context #{cluster_name} label --overwrite #{label[:resource]} #{label[:name]} #{label["value"]}`
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

  def each_service(method)
    app_config._service_order.each do |name|
      service = app_config[:services][name]
      service._type.classify.constantize.new(cluster_name: cluster_name, namespace: namespace, file_path: file_path).send(method, service)
    end
  end

  def upgrade
    each_service(:upgrade)
  end
end

