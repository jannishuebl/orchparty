require 'pathname'
module Orchparty
  class DSLParser
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def parse
      file_content = File.read(filename)
      builder = RootBuilder.new
      builder.instance_eval(file_content, filename)
      builder._build
    end
  end

  class Builder
    def self.build(*args, block)
      builder = self.new(*args)
      builder.instance_eval(&block)
      builder._build
    end
  end

  class RootBuilder < Builder

    def initialize
      @root = AST::Root.new(applications: {}, mixins: {})
    end

    def import(rel_file)
      old_file_path = Pathname.new(caller[0][/[^:]+/]).parent
      rel_file_path = Pathname.new rel_file
      new_file_path = old_file_path + rel_file_path
      file_content = File.read(new_file_path)
      instance_eval(file_content, new_file_path.expand_path.to_s)
    end

    def application(name, &block)
      @root.applications[name] = ApplicationBuilder.build(name, block)
      self
    end

    def mixin(name, &block)
      @root.mixins[name] = MixinBuilder.build(name, block)
      self
    end

    def _build
      @root
    end
  end

  class MixinBuilder < Builder

    def initialize(name)
      @mixin = AST::Mixin.new(name: name, 
                              services: {}, 
                              mixins: {},
                              volumes: {},
                              networks: {})
    end

    def service(name, &block)
      result = ServiceBuilder.build(name, block)
      @mixin.services[name] = result
      @mixin.mixins[name] = result
      self
    end

    def mixin(name, &block)
      @mixin.mixins[name] = ServiceBuilder.build(name, block)
    end

    def volumes(&block)
      @mixin.volumes = HashBuilder.build(block)
    end

    def networks(&block)
      @mixin.networks = HashBuilder.build(block)
    end

    def _build
      @mixin
    end
  end

  class ApplicationBuilder < Builder

    def initialize(name)
      @application = AST::Application.new(name: name,
                                          services: {},
                                          mix: [],
                                          mixins: {},
                                          volumes: {})
    end

    def mix(name)
      @application.mix << name
    end

    def mixin(name, &block)
      @application.mixins[name] = CommonBuilder.build(block)
      self
    end

    def all(&block)
      @application.all = AllBuilder.build(block)
      self
    end

    def variables(&block)
      @application._variables = HashBuilder.build(block)
      self
    end

    def volumes(&block)
      @application.volumes = HashBuilder.build(block)
      self
    end

    def networks(&block)
      @application.networks = HashBuilder.build(block)
    end

    def service(name, &block)
      @application.services[name] = ServiceBuilder.build(name, block)
      self
    end

    def _build
      @application
    end
  end

  class HashBuilder < Builder

    def method_missing(_, *values, &block)
      if block_given?
        value = HashBuilder.build(block)
        if values.count == 1
          @hash ||= {}
          @hash[values.first.to_sym] = value
        else
          @hash ||= []
          @hash << value
        end
      else
        value = values.first
        if value.is_a? Hash
          @hash ||= {}
          key, value = value.first
          @hash[key.to_sym] = value
        else
          @hash ||= []
          @hash << value
        end
      end
      self
    end

    def _build
      @hash || {}
    end
  end

  class CommonBuilder < Builder

    def initialize
      @service = AST::Service.new(_mix: [])
    end

    def mix(name)
      @service._mix << name
    end

    def method_missing(name, *values, &block)
      if block_given?
        @service[name] = HashBuilder.build(block)
      else
        @service[name] = values.first
      end
    end

    def _build
      @service
    end

    def variables(&block)
      @service._variables = HashBuilder.build(block)
      self
    end
  end

  class AllBuilder < CommonBuilder
  end

  class ServiceBuilder < CommonBuilder

    def initialize(name)
      @service = AST::Service.new(name: name, _mix: [])
    end
  end
end
