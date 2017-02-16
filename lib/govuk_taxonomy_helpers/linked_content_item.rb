module GovukTaxonomyHelpers
  class LinkedContentItem
    extend Forwardable
    attr_reader :name, :content_id, :base_path, :children
    attr_accessor :parent
    attr_reader :taxons
    def_delegators :tree, :map, :each

    def initialize(name:, base_path:, content_id:)
      @name = name
      @content_id = content_id
      @base_path = base_path
      @children = []
      @taxons = []
    end

    def <<(child_node)
      child_node.parent = self
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

    def ancestors
      if parent.nil?
        []
      else
        parent.ancestors + [parent]
      end
    end

    def breadcrumb_trail
      ancestors + [self]
    end

    def taxons_with_ancestors
      taxons.flat_map(&:breadcrumb_trail)
    end

    def count
      tree.count
    end

    def root?
      parent.nil?
    end

    def depth
      return 0 if root?
      1 + parent.depth
    end

    def add_taxon(taxon_node)
      taxons << taxon_node
    end

    def inspect
      "LinkedContentItem(name: #{name}, content_id: #{content_id}, base_path: #{base_path})"
    end
  end
end
