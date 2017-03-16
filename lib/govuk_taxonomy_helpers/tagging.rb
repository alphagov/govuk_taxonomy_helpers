module GovukTaxonomyHelpers
  class Tagging
    attr_reader :taxons

    def initialize(taxons: [])
      @taxons = taxons
    end

    # Get all linked taxons and their ancestors
    #
    # @return [Array] all taxons that this content item can be found in
    def taxons_with_ancestors
      taxons.flat_map(&:breadcrumb_trail) # TODO: dedupe
    end

    # Link this content item to a taxon
    #
    # @param taxon_node [LinkedContentItem] A taxon content item
    def add_taxon(taxon_node)
      taxons << taxon_node
    end

    # @return [String] the string representation of the content item
    def inspect
      "Content(title: '#{title}', content_id: '#{content_id}', base_path: '#{base_path}')"
    end
  end
end
