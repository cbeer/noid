# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "noid/version"

Gem::Specification.new do |s|
  s.name        = "noid"
  s.version     = Noid::VERSION
  s.authors     = ["TODO: Write your name"]
  s.email       = ["chris_beer@wgbh.org"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "noid"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "backports"
  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "rspec", ">= 2.0"
  s.add_development_dependency "rcov", ">= 0"
end
