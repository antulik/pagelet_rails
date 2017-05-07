# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'pagelet_rails/version'

Gem::Specification.new do |s|
  s.name        = 'pagelet_rails'
  s.version     = PageletRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Anton Katunin']
  s.email       = ['antulik@gmail.com']
  s.homepage    = 'https://github.com/antulik/pagelet_rails'
  s.summary     = 'Improve perceived performance of your rails application with minimum effort'
  s.description = 'Improve perceived performance of your rails application with minimum effort'
  s.license     = 'MIT'

  s.add_dependency 'rails', '>= 4.0.0'
  s.add_dependency 'ejs'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'better_errors'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
