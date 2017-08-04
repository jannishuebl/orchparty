module Orchparty
  module Plugin
    @plugins = {}

    def self.load_plugin(name)
      begin
        require "orchparty/plugins/#{name}"
        raise "Plugin didn't correctly register itself" unless @plugins[name]
        @plugins[name]
      rescue LoadError
        puts "could not load the plugin #{name}, you might install it as a gem or you need to write it by your self ;)"
        false
      end
    end

    def self.plugins
      @plugins
    end

    def self.register_plugin(name, mod)
      @plugins[name] = mod
    end
  end
end