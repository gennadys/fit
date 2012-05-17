$:.push File.expand_path("../lib", __FILE__)
require "fit/version"

Gem::Specification.new do |s|
  s.name        = "fit"
  s.version     = Fit::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "TBC"
  s.email       = "jeff@tjwallace.ca"
  s.homepage    = "http://github.com/tjwallace/fit"
  s.description = "TBC"
  s.authors     = ['Jeff Wallace']

  s.files         = Dir["lib/**/*"]
  s.test_files    = Dir["spec/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency('bindata', '~> 1.4')
  s.add_dependency('activesupport')
end