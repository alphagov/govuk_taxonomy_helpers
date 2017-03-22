module GovukTaxonomyHelpers
  Dir[File.dirname(__FILE__) + '/govuk_taxonomy_helpers/*.rb'].each do |file|
    require file
  end
end
