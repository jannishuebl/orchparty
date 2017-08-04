# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orchparty/version'

Gem::Specification.new do |spec|
  spec.name          = "orchparty"
  spec.version       = Orchparty::VERSION
  spec.authors       = ["Jannis Huebl"]
  spec.email         = ["jannis.huebl@gmail.com"]

  spec.summary       = %q{Write your orchestration configuration with a Ruby DSL that allows you to have mixins, imports and variables.}
  spec.description   = <<-EOF
    With this gem you can write docker-compose like orchestration configuration with a Ruby DSL, that supports mixins, imports and variables.!
    Out of this you can generate docker-compose.yml v1 or v2. 
  EOF
  spec.homepage      = "https://orch.party"
  spec.license       = "LGPL-3.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hashie", "~> 3.5.6"
  spec.add_dependency "gli", "~> 2.16.0"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
