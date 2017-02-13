require_relative 'spec_helper'
require_relative 'content_item_helper'
require 'govuk_taxonomy_helpers/publishing_api_linked_edition_parser'

RSpec.describe GovukTaxonomyHelpers::LinkedEdition do
  let(:root_node) { GovukTaxonomyHelpers::LinkedEdition.new(name: "root-id", content_id: "abc", base_path: "/root-id") }
  let(:child_node_1) { GovukTaxonomyHelpers::LinkedEdition.new(name: "child-1-id", content_id: "abc", base_path: "/child-1-id") }

  describe "#<<(child_node)" do
    it "makes one node the child of another node" do
      root_node << child_node_1

      expect(root_node.tree).to include child_node_1
      expect(child_node_1.parent_node).to eq root_node
    end
  end

  describe "#tree" do
    context "given a node with a tree of successors" do
      it "returns an array representing a pre-order traversal of the tree" do
        child_node_2 = GovukTaxonomyHelpers::LinkedEdition.new(name: "child-2-id", content_id: "abc", base_path: "/child-2-id")
        child_node_3 = GovukTaxonomyHelpers::LinkedEdition.new(name: "child-3-id", content_id: "abc", base_path: "/child-3-id")

        root_node << child_node_1
        child_node_1 << child_node_3
        child_node_1 << child_node_2

        expect(root_node.tree.count).to eq 4
        expect(root_node.tree.first).to eq root_node
        expect(root_node.tree.map(&:name)).to eq %w(root-id child-1-id child-3-id child-2-id)
        expect(child_node_1.tree.map(&:name)).to eq %w(child-1-id child-3-id child-2-id)
      end
    end

    context "given a single node" do
      it "returns an array containing only that node" do
        expect(root_node.tree.map(&:name)).to eq %w(root-id)
      end
    end
  end

  describe "#root?" do
    before do
      root_node << child_node_1
    end

    it "returns true when a node is the root" do
      expect(root_node.root?).to be
    end

    it "returns false when a node is not the root" do
      expect(child_node_1.root?).to_not be
    end
  end

  describe "#node_depth" do
    it "returns the depth of the node in its tree" do
      child_node_2 = GovukTaxonomyHelpers::LinkedEdition.new(name: "child-2-id", content_id: "abc", base_path: "/child-2-id")
      root_node << child_node_1
      child_node_1 << child_node_2

      expect(root_node.node_depth).to eq 0
      expect(child_node_1.node_depth).to eq 1
      expect(child_node_2.node_depth).to eq 2
    end
  end

  describe "#count" do
    it "returns the total number of nodes in the tree" do
      root_node << child_node_1

      expect(root_node.count).to eq 2
    end
  end
end
