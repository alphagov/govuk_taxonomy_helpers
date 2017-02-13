module GovukTaxonomyHelpers
  class LinkedEdition
    extend Forwardable
    attr_reader :name, :content_id, :base_path, :children
    attr_accessor :parent_node
    def_delegators :tree, :map, :each

    def initialize(name:, base_path:, content_id:)
      @name = name
      @content_id = content_id
      @base_path = base_path
      @children = []
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
  end

end
