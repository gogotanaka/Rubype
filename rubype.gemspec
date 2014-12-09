# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubype/version'

Gem::Specification.new do |spec|
  spec.name          = "rubype"
  spec.version       = Rubype::VERSION
  spec.authors       = ["gogotanaka"]
  spec.email         = ["mail@tanakakazuki.com"]
  spec.summary       = %q{Ruby with type.}
  spec.description   = %q{Ruby with type.}
  spec.homepage      = "http://gogotanaka.me/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
