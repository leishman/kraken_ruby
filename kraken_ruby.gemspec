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

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"

  gem.add_dependency "httparty"
  gem.add_dependency "hashie"
  gem.add_dependency "Base64"
  gem.add_dependency "addressable/uri"
end
