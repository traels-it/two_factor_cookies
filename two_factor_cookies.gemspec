$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "two_factor_cookies/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "two_factor_cookies"
  spec.version     = TwoFactorCookies::VERSION
  spec.authors     = ["Nicolai Bach Woller"]
  spec.email       = ["woller@traels.it"]
  spec.homepage    = "https://traels.it"
  spec.summary     = "Simple two factor logon - with Twilio SMS for code delivery"
  spec.description = "The aim is to be configurable and work with as many kinds of authentication as possible."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = 'https://rubygems.org'

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 5.0"
  spec.add_dependency 'rotp', '5.1.0'
  spec.add_dependency 'twilio-ruby', '~> 5.1'

  spec.add_development_dependency 'm'
  spec.add_development_dependency 'minitest-spec-rails'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'sqlite3'
end
