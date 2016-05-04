lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "omniauth-bbva/version"

Gem::Specification.new do |gem|
  gem.add_dependency "oauth2",     "~> 1.0"
  gem.add_dependency "omniauth",   "~> 1.2"
  gem.add_dependency "httparty"

  gem.add_development_dependency "bundler", "~> 1.0"

  gem.authors       = ["Abian Marrero"]
  gem.email         = ["abian.marrero@the-cocktail.com"]
  gem.description   = "BBVA Oauth2 API"
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/abmm/omniauth-bbva"
  gem.licenses      = %w(MIT)

  gem.executables   = `git ls-files -- bin/*`.split("\n").collect { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth-bbva"
  gem.require_paths = %w(lib)
  gem.version       = OmniAuth::Bbva::VERSION
end
