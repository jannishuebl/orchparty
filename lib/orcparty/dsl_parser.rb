require 'docile'
module Orcparty
  class DSLParser
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def parse
      file_content = File.read(filename)
      Docile.dsl_eval(RootBuilder.new, &lambda { eval(file_content) }).build
    end
  end

  class RootBuilder

    def initialize
      @root = AST::Root.new(applications: {}, mixins: {})
    end
    def application(name, &block)
      @root.applications[name] = Docile.dsl_eval(ApplicationBuilder.new(name), &block).build
      self
    end

    def mixin(name, &block)
      @root.mixins[name] = Docile.dsl_eval(MixinBuilder.new(name), &block).build
      self
    end

    def build
      @root
    end
  end

  class MixinBuilder

    def initialize(name)
      @mixin = AST::Mixin.new(name: name, services: {})
    end

    def service(name, &block)
      builder  = ServiceBuilder.new(name)
      builder.instance_eval(&block)
      @mixin.services[name] = builder._build
      self
    end

    def build
      @mixin
    end
  end

  class ApplicationBuilder

    def initialize(name)
      @application = AST::Application.new(name: name, services: {}, mixins: [])
    end

    def mix(name)
      @application.mixins << name
    end

    def all(&block)
      builder  = AllBuilder.new
      builder.instance_eval(&block)
      @application.all = builder._build
      self
    end

    def variables(&block)
      builder  = VariableBuilder.new
      builder.instance_eval(&block)
      @application.variables = builder._build
      self
    end

    def service(name, &block)
      builder  = ServiceBuilder.new(name)
      builder.instance_eval(&block)
      @application.services[name] = builder._build
      self
    end

    def build
      @application
    end
  end

  class HashBuilder

    def initialize
      @hash = {}
    end

    def method_missing(_, value)
      key, value = value.first
      @hash[key.to_sym] = value
      self
    end

    def _build
      @hash
    end
  end

  class LabelBuilder < HashBuilder
  end

  class VariableBuilder < HashBuilder
  end

  class CommonBuilder

    def initialize
      @service = AST::Service.new(mix: [])
    end

    def labels(&block)
      builder  = LabelBuilder.new
      builder.instance_eval(&block)
      @service.labels = builder._build
      self
    end

    def mix(name)
      @service.mix << name
    end

    def method_missing(name, value)
      @service[name] = value
    end

    def _build
      @service
    end

    def variables(&block)
      builder  = VariableBuilder.new
      builder.instance_eval(&block)
      @service.variables = builder._build
      self
    end
  end

  class AllBuilder < CommonBuilder
  end

  class ServiceBuilder < CommonBuilder

    def initialize(name)
      @service = AST::Service.new(name: name, mix: [])
    end
  end
end
