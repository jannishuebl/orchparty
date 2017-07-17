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
    def application(name, &block)
      @name = name
      @block = block
      self
    end

    def build
      Docile.dsl_eval(ApplicationBuilder.new(@name), &@block).build
    end
  end

  class ApplicationBuilder

    def initialize(name)
      @application = AST::Application.new(name: name, services: [])
    end

    def all(&block)
      builder  = AllBuilder.new
      builder.instance_eval(&block)
      @application.all = builder._build
      self
    end

    def service(name, &block)
      builder  = ServiceBuilder.new(name)
      builder.instance_eval(&block)
      @application.services << builder._build
      self
    end

    def build
      @application
    end
  end

  class LabelBuilder

    def initialize
      @labels = {}
    end

    def label(value)
      key, value = value.first
      @labels[key.to_sym] = value
      self
    end

    def _build
      @labels
    end
  end

  class CommonBuilder

    def initialize
      @service = AST::Service.new
    end

    def labels(&block)
      builder  = LabelBuilder.new
      builder.instance_eval(&block)
      @service.labels = builder._build
      self
    end

    def method_missing(name, value)
      @service[name] = value
    end

    def _build
      @service
    end
  end

  class AllBuilder < CommonBuilder
  end

  class ServiceBuilder < CommonBuilder

    def initialize(name)
      @service = AST::Service.new(name: name)
    end
  end
end
