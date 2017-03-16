require_relative 'spec_helper'
require 'govuk_taxonomy_helpers/tagging'
require 'govuk_taxonomy_helpers/taxon'

RSpec.describe GovukTaxonomyHelpers::Tagging do
  let(:root_node) { GovukTaxonomyHelpers::Taxon.new(title: "root-id", content_id: "abc", base_path: "/root-id") }
  let(:child_node_1) { GovukTaxonomyHelpers::Taxon.new(title: "child-1-id", content_id: "def", base_path: "/child-1-id") }
  let(:child_node_2) { GovukTaxonomyHelpers::Taxon.new(title: "child-2-id", content_id: "ghi", base_path: "/child-2-id") }
  let(:content_item) { GovukTaxonomyHelpers::Tagging.new }
  let(:another_taxon) do
    GovukTaxonomyHelpers::Taxon.new(
      title: "another-taxon",
      content_id: "jkl",
      base_path: "/another-taxon"
    )
  end

  before do
    root_node << child_node_1
    root_node << child_node_2
    child_node_1 << another_taxon
  end

  describe "#taxons" do
    it "includes only the directly linked taxons" do
      content_item.add_taxon(child_node_2)

      expect(content_item.taxons.map(&:title)).to eq ["child-2-id"]
    end
  end

  describe "#taxons_with_ancestors" do
    it "includes all of the taxons and all of their anscestors" do
      content_item.add_taxon(child_node_2)
      content_item.add_taxon(another_taxon)

      expect(content_item.taxons_with_ancestors.map(&:title).sort.uniq).to eq %w(another-taxon child-1-id child-2-id root-id)
    end
  end
end
