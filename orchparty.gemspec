# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orchparty/version'

Gem::Specification.new do |spec|
  spec.name          = "orchparty"
  spec.version       = Orchparty::VERSION
  spec.authors       = ["Jannis Huebl"]
  spec.email         = ["jannis.huebl@gmail.com"]

  spec.summary       = %q{Generate configuration for orchestration plattforms}
  spec.description   = %q{Write your orchestration configuration with a Ruby DSL that allows you to have mixins, imports and variables.}
  spec.homepage      = "https://orch.party"
  spec.license       = "GNU Lesser General Public License v3.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hashie", "~> 3.5.6"
  spec.add_dependency "docile", "~> 1.1.5"
  spec.add_dependency "thor", "~> 0.19.4"
  spec.add_dependency 'psych', '~> 2.2', '>= 2.2.4'
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
