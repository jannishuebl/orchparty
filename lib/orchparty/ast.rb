require 'hashie'

module Orchparty
  class AST
    class Node < ::Hashie::Mash
      include Hashie::Extensions::DeepMerge
      include Hashie::Extensions::DeepMergeConcat
      include Hashie::Extensions::MethodAccess
      include Hashie::Extensions::Mash::KeepOriginalKeys
    end

    def self.hash(args = {})
      Node.new.merge(args)
    end

    def self.array(args = [])
      args
    end

    def self.root(args = {})
      Node.new(applications: {}, _mixins: {}).merge(args)
    end

    def self.mixin(args = {})
      Node.new({services: {}, _mixins: {}, volumes: {}, _variables: {}, networks: {}}).merge(args)
    end

    def self.application(args = {})
      Node.new({services: {}, _mixins: {}, _mix:[], volumes: {}, _variables: {}, networks: {}}).merge(args)
    end

    def self.all(args = {})
      Node.new(_mix:[], _variables: {}).merge(args)
    end

    def self.application_mixin(args = {})
      Node.new(_mix:[], _variables: {}).merge(args)
    end

    def self.service(args = {})
      Node.new(_mix:[], _variables: {}).merge(args)
    end
  end
end
