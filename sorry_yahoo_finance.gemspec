# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sorry_yahoo_finance/version'

Gem::Specification.new do |spec|
  spec.name          = "sorry_yahoo_finance"
  spec.version       = SorryYahooFinance::VERSION
  spec.authors       = ["gogotanaka"]
  spec.email         = ["qlli.illb@gmail.com"]
  spec.summary       = %q{acquire a stock infomations form yahoofinance, although I am very sorry to Yahoo!.}
  spec.description   = %q{acquire a stock infomations form yahoofinance, although I am very sorry to Yahoo!.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", ">= 10.0.0"
  spec.add_development_dependency "rspec"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "openurl"
  spec.add_runtime_dependency "whenever"
end
