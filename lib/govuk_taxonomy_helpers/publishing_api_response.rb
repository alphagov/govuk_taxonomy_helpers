require 'govuk_taxonomy_helpers/linked_content_item'

module GovukTaxonomyHelpers
  class LinkedContentItem
    # Extract a LinkedContentItem from publishing api response data.
    #
    # @param content_item [Hash] Publishing API `get_content` response hash
    # @param expanded_links [Hash] Publishing API `get_expanded_links` response hash
    # @param name_field [String] The field to use for content item names
    # @return [LinkedContentItem]
    # @see http://www.rubydoc.info/gems/gds-api-adapters/GdsApi/PublishingApiV2#get_content-instance_method
    # @see http://www.rubydoc.info/gems/gds-api-adapters/GdsApi%2FPublishingApiV2:get_expanded_links
    def self.from_publishing_api(content_item:, expanded_links:, name_field: "title")
      PublishingApiResponse.new(
        content_item: content_item,
        expanded_links: expanded_links,
        name_field: name_field
      ).linked_content_item
    end
  end

  class PublishingApiResponse
    attr_accessor :linked_content_item

    def initialize(content_item:, expanded_links:, name_field: "title")
      @linked_content_item = LinkedContentItem.new(
        name: content_item[name_field],
        content_id: content_item["content_id"],
        base_path: content_item["base_path"]
      )

      @name_field = name_field

      add_expanded_links(expanded_links)
    end

  private

    def add_expanded_links(expanded_links_response)
      child_taxons = expanded_links_response["expanded_links"]["child_taxons"]
      parent_taxons = expanded_links_response["expanded_links"]["parent_taxons"]
      taxons = expanded_links_response["expanded_links"]["taxons"]

      if !child_taxons.nil?
        child_nodes = child_taxons.each do |child|
          linked_content_item << parse_nested_child(child)
        end
      end

      if !parent_taxons.nil?
        # Assume no taxon has multiple parents
        single_parent = parent_taxons.first

        parse_nested_parent(single_parent) << linked_content_item
      end

      if !taxons.nil?
        taxon_nodes = taxons.each do |taxon|
          taxon_node = parse_nested_parent(taxon)
          linked_content_item.add_taxon(taxon_node)
        end
      end
    end

      attr_reader :name_field

      def parse_nested_child(nested_item)
        nested_linked_content_item = LinkedContentItem.new(
          name: nested_item[name_field],
          content_id: nested_item["content_id"],
          base_path: nested_item["base_path"]
        )

        child_taxons = nested_item["links"]["child_taxons"]

        if !child_taxons.nil?
          child_nodes = child_taxons.each do |child|
            nested_linked_content_item << parse_nested_child(child)
          end
        end

        nested_linked_content_item
      end

      def parse_nested_parent(nested_item)
        nested_linked_content_item = LinkedContentItem.new(
          name: nested_item[name_field],
          content_id: nested_item["content_id"],
          base_path: nested_item["base_path"]
        )

        parent_taxons = nested_item["links"]["parent_taxons"]

        if !parent_taxons.nil?
          single_parent = parent_taxons.first
          parse_nested_parent(single_parent) << nested_linked_content_item
        end

        nested_linked_content_item
      end
  end
end
