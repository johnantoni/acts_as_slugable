$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'acts_as_slugable/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'acts_as_slugable'
  s.version     = Slugable::VERSION
  s.authors     = ['Arne De Herdt']
  s.email       = ['arne.de.herdt@gmail.com']
  s.homepage    = ''
  s.summary     = 'Gem that implements the old behavior of acts_as_slugable Rails Plugin.'
  s.description = 'This gem is an attempt at converting an old Rails 2 plugin into a new Gem.'
  s.license     = 'MIT'
  s.platform    = Gem::Platform::RUBY

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4.1.8'

  s.add_development_dependency 'sqlite3'
end
