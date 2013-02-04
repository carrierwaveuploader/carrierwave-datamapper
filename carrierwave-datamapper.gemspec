# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "carrierwave/datamapper/version"

Gem::Specification.new do |s|
  s.name        = "carrierwave-datamapper"
  s.version     = Carrierwave::Datamapper::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jonas Nicklas", "Trevor Turk", "Piotr Solnica"]
  s.email       = ["jonas.nicklas@gmail.com"]
  s.homepage    = "https://github.com/jnicklas/carrierwave-datamapper"
  s.summary     = %q{Datamapper support for CarrierWave}
  s.description = %q{Datamapper support for CarrierWave}

  s.rubyforge_project = "carrierwave-datamapper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "dm-core", ["~> 1.1"]
  s.add_dependency "carrierwave", ["~> 0.8.0"]

  s.add_development_dependency "rake", ["~> 0.9.2"]
  s.add_development_dependency "rspec", ["~> 2.8"]
  s.add_development_dependency "dm-validations", ["~> 1.1"]
  s.add_development_dependency "dm-migrations", ["~> 1.1"]
  s.add_development_dependency "dm-sqlite-adapter", ["~> 1.1"]
end
