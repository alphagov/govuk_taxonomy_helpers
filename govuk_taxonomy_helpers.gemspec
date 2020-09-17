lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "govuk_taxonomy_helpers/version"

Gem::Specification.new do |spec|
  spec.name          = "govuk_taxonomy_helpers"
  spec.version       = GovukTaxonomyHelpers::VERSION
  spec.authors       = ["Government Digital Service"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]
  spec.summary       = "Parses the taxonomy of GOV.UK into a browseable tree structure."
  spec.homepage      = "https://github.com/alphagov/govuk_taxonomy_helpers"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "pry-byebug", "~> 3.4"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop-govuk", "~> 3.15"
  spec.add_development_dependency "yard", "~> 0.9.8"
end
