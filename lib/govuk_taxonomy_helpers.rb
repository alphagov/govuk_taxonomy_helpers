module GovukTaxonomyHelpers
  Dir[File.dirname(__FILE__) + "/govuk_taxonomy_helpers/*.rb"].sort.each do |file|
    require file
  end
end
