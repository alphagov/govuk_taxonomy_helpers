module GovukTaxonomyHelpers
  class Taxon
    extend Forwardable

    attr_accessor :parent
    attr_reader :children
    attr_reader :title
    attr_reader :content_id
    attr_reader :base_path
    attr_reader :internal_name

    def_delegators :tree, :map, :each

    # @param title [String] the user facing name for the content item
    # @param base_path [String] the relative URL, starting with a leading "/"
    # @param content_id [UUID] unique identifier of the content item
    # @param internal_name [String] an internal name for the content item
    def initialize(title:, base_path:, content_id:, internal_name: nil, **kwargs)
      @title = title
      @content_id = content_id
      @base_path = base_path
      @internal_name = internal_name
      @children = []
      @taxons = []
    end

    # Add a LinkedContentItem as a child of this one
    def <<(child_node)
      child_node.parent = self
      @children << child_node
    end

    # Get taxons in the taxon's branch of the taxonomy.
    #
    # @return [Array] all taxons in this branch of the taxonomy, including the content item itself
    def tree
      return [self] if @children.empty?

      @children.each_with_object([self]) do |child, tree|
        tree.concat(child.tree)
      end
    end

    # Get descendants of a taxon
    #
    # @return [Array] all taxons in this branch of the taxonomy, excluding the content item itself
    def descendants
      tree.tap(&:shift)
    end

    # Get ancestors of a taxon
    #
    # @return [Array] all taxons in the path from the root of the taxonomy to the parent taxon
    def ancestors
      if parent.nil?
        []
      else
        parent.ancestors + [parent]
      end
    end

    # Get a breadcrumb trail for a taxon
    #
    # @return [Array] all taxons in the path from the root of the taxonomy to this taxon
    def breadcrumb_trail
      ancestors + [self]
    end

    # @return [Integer] the number of taxons in this branch of the taxonomy
    def count
      tree.count
    end

    # @return [Boolean] whether this taxon is the root of its taxonomy
    def root?
      parent.nil?
    end

    # @return [Integer] the number of taxons between this taxon and the taxonomy root
    def depth
      return 0 if root?
      1 + parent.depth
    end

    # @return [String] the string representation of the content item
    def inspect
      "Taxon(title: '#{title}', internal_name: '#{internal_name}', content_id: '#{content_id}', base_path: '#{base_path}')"
    end
  end
end
