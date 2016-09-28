$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pagelet_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pagelet_rails"
  s.version     = PageletRails::VERSION
  s.authors     = ["Anton Katunin"]
  s.email       = ["antulik@gmail.com"]
  s.homepage    = "https://github.com/antulik/pagelet_rails"
  s.summary     = "Improve perceived performance of your rails application with minimum effort"
  s.description = "Improve perceived performance of your rails application with minimum effort"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.0.0"
  s.add_dependency "ejs"

  s.add_development_dependency "sqlite3"
end
