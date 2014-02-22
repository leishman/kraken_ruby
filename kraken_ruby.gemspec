# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kraken_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "kraken_ruby"
  spec.version       = KrakenRuby::VERSION
  spec.authors       = ["Alexander Leishman"]
  spec.email         = ["leishman3@gmail.com"]
  spec.description   = ["Wrapper for Kraken Exchange API"]
  spec.summary       = ["Wrapper for Kraken Exchange API"]
  spec.homepage      = "https://www.kraken.com/help/api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "fakeweb", "~> 1.3.0"
  spec.add_development_dependency "rake"

  gem.add_dependency "httparty", ">= 0.8.3"
  gem.add_dependency "hashie", ">= 1.2.0"
end
