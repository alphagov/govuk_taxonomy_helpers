require 'govuk_taxonomy_helpers/linked_content_item'

module GovukTaxonomyHelpers
  class LinkedContentItem
    # Extract a LinkedContentItem from publishing api response data.
    #
    # @param content_item [Hash] Publishing API `get_content` response hash
    # @param expanded_links [Hash] Publishing API `get_expanded_links` response hash
    # @return [LinkedContentItem]
    # @see http://www.rubydoc.info/gems/gds-api-adapters/GdsApi/PublishingApiV2#get_content-instance_method
    # @see http://www.rubydoc.info/gems/gds-api-adapters/GdsApi%2FPublishingApiV2:get_expanded_links
    def self.from_publishing_api(content_item:, expanded_links:)
      PublishingApiResponse.new(
        content_item: content_item,
        expanded_links: expanded_links,
      ).linked_content_item
    end

    # Extract a LinkedContentItem from publishing api's message queue payload.
    #
    # @param expanded_content_item [Hash] Publishing API message queue payload
    # @return [LinkedContentItem]
    def self.from_publishing_api_downstream(expanded_content_item)
      PublishingApiResponse.new(
        content_item: expanded_content_item,
        expanded_links: expanded_content_item,
      ).linked_content_item
    end
  end

  class PublishingApiResponse
    attr_accessor :linked_content_item

    # @param content_item [Hash] Publishing API `get_content` response hash
    # @param expanded_links [Hash] Publishing API `get_expanded_links` response hash
    def initialize(content_item:, expanded_links:)
      details = content_item["details"] || {}

      @linked_content_item = LinkedContentItem.new(
        title: content_item["title"],
        internal_name: details["internal_name"],
        content_id: content_item["content_id"],
        base_path: content_item["base_path"]
      )

      add_expanded_links(expanded_links)
    end

  private

    def extract_links(item)
      item["expanded_links"] || item["links"]
    end

    def add_expanded_links(expanded_links_response)
      direct_links = extract_links(expanded_links_response)

      child_taxons = direct_links["child_taxons"]
      parent_taxons = direct_links["parent_taxons"]
      taxons = direct_links["taxons"]

      if !child_taxons.nil?
        child_taxons.each do |child|
          linked_content_item << parse_nested_child(child)
        end
      end

      if !parent_taxons.nil?
        # Assume no taxon has multiple parents
        single_parent = parent_taxons.first

        parse_nested_parent(single_parent) << linked_content_item
      end

      if !taxons.nil?
        taxons.each do |taxon|
          taxon_node = parse_nested_parent(taxon)
          linked_content_item.add_taxon(taxon_node)
        end
      end
    end

    def parse_nested_child(nested_item)
      details = nested_item["details"] || {}
      links = nested_item["links"] || {}

      nested_linked_content_item = LinkedContentItem.new(
        title: nested_item["title"],
        internal_name: details["internal_name"],
        content_id: nested_item["content_id"],
        base_path: nested_item["base_path"]
      )

      child_taxons = links["child_taxons"]

      if !child_taxons.nil?
        child_taxons.each do |child|
          nested_linked_content_item << parse_nested_child(child)
        end
      end

      nested_linked_content_item
    end

    def parse_nested_parent(nested_item)
      details = nested_item["details"] || {}
      links = nested_item["links"] || {}

      nested_linked_content_item = LinkedContentItem.new(
        title: nested_item["title"],
        internal_name: details["internal_name"],
        content_id: nested_item["content_id"],
        base_path: nested_item["base_path"]
      )

      parent_taxons = links["parent_taxons"]

      if !parent_taxons.nil?
        single_parent = parent_taxons.first
        parse_nested_parent(single_parent) << nested_linked_content_item
      end

      nested_linked_content_item
    end
  end
end
