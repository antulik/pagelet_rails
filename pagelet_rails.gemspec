$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pagelet_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pagelet_rails"
  s.version     = PageletRails::VERSION
  s.authors     = ["Anton Katunin"]
  s.email       = ["antulik@gmail.com"]
  s.homepage    = "http://google.com"
  s.summary     = "TO DO: Summary of PageletRails."
  s.description = "TO DO: Description of PageletRails."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0"

  s.add_development_dependency "sqlite3"
end
