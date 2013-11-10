# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mock_beaneater/version'

Gem::Specification.new do |spec|
  spec.name          = "mock_beaneater"
  spec.version       = MockBeaneater::VERSION
  spec.authors       = ["Sean Xie"]
  spec.email         = ["seanx@referralcandy.com"]
  spec.description   = 'Beaneater mock for testing'
  spec.summary       = 'Beaneater mock for testing'
  spec.homepage      = 'https://rubygems.org/gems/mock_beaneater'
  spec.licenses      = ["MIT"]

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency             "algorithms", ">= 0.6.1"
  spec.add_development_dependency "bundler"   , "~> 1.3"
  spec.add_development_dependency "rspec"     , ">= 2.9.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "coveralls"
end
