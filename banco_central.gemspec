# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'banco_central/version'

Gem::Specification.new do |spec|
  spec.name          = "banco_central"
  spec.version       = BancoCentral::VERSION
  spec.authors       = ["Henrique G. Testa"]
  spec.email         = ["hgtesta@gmail.com"]

  spec.summary       = %q{Utility to consume Banco Central Webservice}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "http://github.com/hgtesta/banco_central"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "savon", "~> 2.11"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "activesupport", "~> 5.0"
end
