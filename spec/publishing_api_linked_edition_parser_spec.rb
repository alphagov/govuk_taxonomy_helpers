require_relative 'spec_helper'
require_relative 'content_item_helper'
require 'govuk_taxonomy_helpers'

RSpec.describe GovukTaxonomyHelpers::PublishingApiLinkedEditionParser do
  let(:edition_response) do
    {
      "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
      "base_path" => "/taxon",
      "title" => "Taxon",
      "internal_name" => "My lovely taxon"
    }
  end

  let(:linked_edition) do
    GovukTaxonomyHelpers.parse_publishing_api_response(
      content_item: edition_response,
      expanded_links: expanded_links_response
    )
  end

  context "content item with multiple levels of descendants" do
    let(:expanded_links_response) do
      grandchild_1 = {
        "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandchild-1",
        "title" => "Grandchild 1",
        "internal_name" => "Root > Child > Grandchild 1",
        "links" => {}
      }

      grandchild_2 = {
        "content_id" => "94aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandchild-2",
        "title" => "Grandchild 2",
        "internal_name" => "Root > Child > Grandchild 2",
        "links" => {}
      }

      child_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/child-1",
        "title" => "Child 1",
        "internal_name" => "Root > Child 1",
        "links" => {
          "child_taxons" => [
            grandchild_1,
            grandchild_2
          ]
        }
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "child_taxons" => [child_1]
        }
      }
    end

    it "parses each level of taxons" do
      expect(linked_edition.name).to eq("Taxon")
      expect(linked_edition.children.map(&:name)).to eq (['Child 1'])
      expect(linked_edition.children.first.children.map(&:name)).to eq(["Grandchild 1", "Grandchild 2"])
    end
  end

  context "content item with no descendants" do
    let(:expanded_links_response) do
      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {}
      }
    end

    it "parses each level of taxons" do
      expect(linked_edition.name).to eq("Taxon")
      expect(linked_edition.children).to be_empty
    end
  end

  context "content item with children but no grandchildren" do
    let(:expanded_links_response) do
      child_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/child-1",
        "title" => "Child 1",
        "internal_name" => "Root > Child 1",
        "links" => {}
      }

      child_2 = {
        "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/child-2",
        "title" => "Child 2",
        "internal_name" => "Root > Child 2",
        "links" => {}
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "child_taxons" => [child_1, child_2]
        }
      }
    end

    it "parses each level of taxons" do
      expect(linked_edition.name).to eq("Taxon")
      expect(linked_edition.children.map(&:name)).to eq(["Child 1", "Child 2"])
      expect(linked_edition.children.map(&:children)).to all(be_empty)
    end
  end

  context "content item with parents and grandparents" do
    let(:expanded_links_response) do
      grandparent_1 = {
        "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandparent-1",
        "title" => "Grandparent 1",
        "links" => {}
      }

      parent_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-1",
        "title" => "Parent 1",
        "links" => {
          "parent_taxons" => [
            grandparent_1
          ]
        }
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "parent_taxons" => [parent_1]
        }
      }
    end

    it "parses the ancestors" do
      expect(linked_edition.name).to eq("Taxon")
      expect(linked_edition.parent.name).to eq("Parent 1")
      expect(linked_edition.ancestors.map(&:name)).to eq(["Grandparent 1", "Parent 1"])
    end
  end


  context "content item with parents and no grandparents" do
    let(:expanded_links_response) do
      parent_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-1",
        "title" => "Parent 1",
        "links" => {}
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "parent_taxons" => [parent_1]
        }
      }
    end

    it "parses the ancestors" do
      expect(linked_edition.name).to eq("Taxon")
      expect(linked_edition.parent.name).to eq("Parent 1")
      expect(linked_edition.ancestors.map(&:name)).to eq(["Parent 1"])
    end
  end

  context "content item with no parents" do
    let(:expanded_links_response) do
      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {}
      }
    end

    it "parses the ancestors" do
      expect(linked_edition.name).to eq("Taxon")
      expect(linked_edition.parent).to be_nil
      expect(linked_edition.ancestors.map(&:name)).to be_empty
    end
  end

  context "content item with multiple parents" do
    let(:expanded_links_response) do
      parent_1 = {
        "content_id" => "74aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-1",
        "title" => "Parent 1",
        "links" => {}
      }

      parent_2 = {
        "content_id" => "84aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-2",
        "title" => "Parent 2",
        "links" => {}
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "parent_taxons" => [parent_1, parent_2]
        }
      }
    end

    it "uses only the first parent" do
      expect(linked_edition.name).to eq("Taxon")
      expect(linked_edition.parent.name).to eq("Parent 1")
      expect(linked_edition.ancestors.map(&:name)).to eq(["Parent 1"])
    end
  end

  context "an edition tagged to multiple taxons" do
    let(:expanded_links_response) do
      grandparent_1 = {
        "content_id" => "22aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandparent-1",
        "title" => "Grandparent 1",
        "links" => {}
      }

      parent_1 = {
        "content_id" => "11aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-1",
        "title" => "Parent 1",
        "links" => {
          "parent_taxons" => [grandparent_1]
        }
      }

      taxon_1 = {
        "content_id" => "00aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/this-is-a-taxon",
        "title" => "Taxon 1",
        "links" => {
          "parent_taxons" => [parent_1]
        }
      }

      grandparent_2 = {
        "content_id" => "03aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/grandparent-2",
        "title" => "Grandparent 2",
        "links" => {}
      }

      parent_2 = {
        "content_id" => "02aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/parent-2",
        "title" => "Parent 2",
        "links" => {
          "parent_taxons" => [grandparent_2]
        }
      }

      taxon_2 = {
        "content_id" => "01aadc14-9bca-40d9-abb4-4f21f9792a05",
        "base_path" => "/this-is-also-a-taxon",
        "title" => "Taxon 2",
        "links" => {
          "parent_taxons" => [parent_2]
        }
      }

      {
        "content_id" => "64aadc14-9bca-40d9-abb4-4f21f9792a05",
        "expanded_links" => {
          "taxons" => [taxon_1, taxon_2]
        }
      }
    end

    it "parses the taxons and their ancestors" do
      expect(linked_edition.parent).to be_nil
      expect(linked_edition.taxons.map(&:name)).to eq(["Taxon 1", "Taxon 2"])
      expect(linked_edition.taxons_with_ancestors.map(&:name).sort).to eq(
        [
          "Grandparent 1", "Grandparent 2",
          "Parent 1", "Parent 2",
          "Taxon 1", "Taxon 2",
        ]
      )
    end
  end
end
