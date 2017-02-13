require "govuk_taxonomy_helpers/version"
require "govuk_taxonomy_helpers/publishing_api_linked_edition_parser"

module GovukTaxonomyHelpers
  def self.parse_publishing_api_response(content_item:, expanded_links:)
    parser = PublishingApiLinkedEditionParser.new(content_item)
    parser.add_expanded_links(expanded_links)
    parser.linked_edition
  end
end
