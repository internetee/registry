$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "depp/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "depp"
  s.version     = Depp::VERSION
  s.authors     = ["Priit Tark", "Martin Lensment"]
  s.email       = ["priit@gitlab.eu", "martin@gitlab.eu"]
  s.homepage    = "https://github.com/domify/depp"
  s.summary     = "EPP/REPP client build as Rails engine."
  s.description = "EPP/REPP client build as Rails engine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.2.1"

  # load env
  s.add_dependency "figaro", ">= 1.1.0"

  # html
  s.add_dependency "haml-rails", ">= 0.9.0"

  # style
  s.add_dependency "sass-rails", ">= 5.0.0"

  # js
  s.add_dependency "uglifier", ">= 2.6.1"     # minifies js
  s.add_dependency "coffee-rails", ">= 4.1.0" # coffeescript support
  s.add_dependency "jquery-rails", ">= 4.0.3" # jquery

  # epp api
  # s.add_dependency "epp", "~> 1.4.2", github: 'gitlabeu/epp'
  s.add_dependency "epp-xml", '>= 0.10.4'
  s.add_dependency "nokogiri", '>= 1.6.6.2'

  # registry related
  s.add_dependency "countries", '>= 0.9.3'
  s.add_dependency "coderay", '>= 1.1.0'
  s.add_dependency "uuidtools", '>= 2.1.4'

  s.add_dependency "kaminari", '~> 0.16.3'

  # s.add_development_dependency "sqlite3"
end
