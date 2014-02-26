# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kraken_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "kraken_ruby"
  spec.version       = KrakenRuby::VERSION
  spec.authors       = ["Alexander Leishman"]
  spec.email         = ["leishman3@gmail.com"]
  spec.description   = %q{"Wrapper for Kraken Exchange API"}
  spec.summary       = %q{"Wrapper for Kraken Exchange API"}
  spec.homepage      = "https://www.kraken.com/help/api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "httparty"
  spec.add_dependency "hashie"
  spec.add_dependency "addressable"
end
