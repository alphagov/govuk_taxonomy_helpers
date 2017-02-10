require "govuk_taxonomy_helpers/version"

# TODO: allow this to work with GET expanded-links in the publishing api
module GovukTaxonomyHelpers
  class Taxon
    extend Forwardable
    attr_reader :name, :content_item, :children
    attr_accessor :parent_node
    def_delegators :tree, :map, :each

    def initialize(content_item:, name_field: "title")
      @name = content_item[name_field]
      @content_item = content_item
      @children = []

      child_taxons = content_item.dig("links", "child_taxons")

      if !child_taxons.nil?
        child_nodes = child_taxons.map do |child|
          Taxon.new(name_field: name_field, content_item: child)
        end

        child_nodes.each do |child_node|
          self << child_node
        end
      end
    end

    def <<(child_node)
      child_node.parent_node = self
      @children << child_node
    end

    def tree
      return [self] if @children.empty?

      @children.each_with_object([self]) do |child, tree|
        tree.concat(child.tree)
      end
    end

    def descendants
      tree.tap(&:shift)
    end

    def count
      tree.count
    end

    def root?
      parent_node.nil?
    end

    def node_depth
      return 0 if root?
      1 + parent_node.node_depth
    end

    def content_id
      content_item["content_id"]
    end
  end

end
